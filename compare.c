#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h>

typedef struct {
    int start;
    int summit;
    int length;
} Node;

int max(int a, int b)
{
    if (a < b)
        return b;
    else
        return a;
}
void swap(Node *a, Node *b) {
    Node tmp = *a;
    *a = *b;
    *b = tmp;
}

int bekijou(int a, int i)
{
    int top4= 1;
    while(i > 0) {
        top4 = top4 * a;
        i--;
    }
    return top4;
}

Node climb (int start) {
    int height = start;//いまいる高さ
    int footsteps = 0;//lengthと同じ
    int local_s = start;//現状の最高の高さ
    int shift = 0;

    for (int j = 0; height > 1; j++)
    {
        if (height % 2 == 1)
        {
            height = height * 3 + 1;
            footsteps += 1;
            local_s = max(local_s, height);
        }
        for (int i = 0;;i++) //priority-encoder
        {
            int beki = bekijou(2, i);
            if ((height & beki) == beki)
            {
                shift = i;
                break;
            }
        }
        if (shift >= 16)//barrel-shifter
        {
            height = height >> 16;
            footsteps += 16;
        }
        else if (shift >= 8)
        {
            height = height >> 8;
            footsteps += 8;
        }
        else if (shift >= 4)
        {
            height = height >> 4;
            footsteps += 4;
        }
        else if (shift >= 2)
        {
            height = height >> 2;
            footsteps += 2;
        }
        else if (shift >= 1)
        {
            height = height >> 1;
            footsteps += 1;
        }
    }
    Node n = {start, local_s, footsteps};
    return n;
    
}

void sorter(Node **top4, Node new_result) {
    if (top4[3]->summit > new_result.summit) {
        return;
    }

    int is_same = 0;
    int index;
    for (int i = 0; i < 4; i++) {
        if (top4[i]->summit == new_result.summit) {
            is_same = 1;
            index = i;
            break;
        }
    }

    if (is_same) {
        if (top4[index]->length < new_result.length) {
            swap(top4[index], &new_result);
        }
        return;
    }

    int idx;
    for (int i = 3; i >= 0; i--) {
        if (top4[i]->summit < new_result.summit) {
            idx = i;
        }
    }

    for (int i = 2; i >= idx; i--) {
        swap(top4[i], top4[i + 1]);
    }
    swap(top4[idx], &new_result);
}

int main () {
    long long start = _rdtsc();
    Node** top4 = malloc(4 * sizeof(Node*));
    int i;

    for (i = 0; i < 4; i++)
    {
        top4[i] = malloc(sizeof(Node));
        top4[i]->start = 0;
        top4[i]->summit = 0;
        top4[i]->length = 0;
    }//top4初期化

    for (i = 0; i < 512; i++)
    {
        Node n = climb(2*i + 1);
        sorter (top4, n);
    }
    long long end = _rdtsc();
    printf("It took %lld clocks\n\n", end - start);

    for (int i = 0; i < 4; i++) {
        printf("Start: %d\n     Summit: %d\n     Length:  %d\n\n", top4[i]->start, top4[i]->summit, top4[i]->length);
    }

    return 0;
}