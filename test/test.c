/*
 * This is a test c program to explore the gumbo parser, help debug the ruby ffi library
 * Author: @isaiah
 */

#include <stdio.h>
#include <stdlib.h>
#include <gumbo.h>
#include <assert.h>

struct site {
    char * name;
    int size;
};

struct domain {
    struct site * site;
    char * name;
};

int
main()
{
    FILE *html = fopen("../../c/gumbo-parser/docs/html/index.html", "r");
    fseek(html, 0, SEEK_END);
    long fsize = ftell(html);
    fseek(html, 0, SEEK_SET);
    char *text = malloc(fsize + 1);
    fread(text, fsize, 1, html);
    fclose(html);
    GumboOutput *output = gumbo_parse(text);
    GumboNode *head;
    const GumboVector root_children = output->root->v.element.children;
    for (int i = 0; i < root_children.length; i++) {
        GumboNode *child = root_children.data[i];
        if (child->type == GUMBO_NODE_ELEMENT &&
            child->v.element.tag == GUMBO_TAG_HEAD) {
            head = child;
        }
    }

    assert(head != NULL);

    GumboVector *head_children = &head->v.element.children;

    for (int i = 0; i < head_children->length; i++) {
        GumboNode *child = head_children->data[i];
        printf("type: %d, %d\n", i, child->type);
        if (child->type == GUMBO_NODE_ELEMENT &&
                child->v.element.tag == GUMBO_TAG_TITLE) {
            if (child->v.element.children.length != 1)
                printf("%s\n", "<empty title>");

            GumboNode* title = child->v.element.children.data[0];
            assert(title->type == GUMBO_NODE_TEXT);
            printf("%s\n", title->v.text.text);
        }
    }

    // clean it
    free(text);
    return 0;
}
