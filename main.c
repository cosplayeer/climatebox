 #include <stdio.h>
#include "guagame/gua_game.h"
#include "guagame/utils.h"
#include "guagame/gua_type.h"
#include "guagame/gua_scene.h"
#include "guagame/gua_label.h"
#include <time.h>
#define log(...) printf(__VA_ARGS__);


/*
����Ŀ��Ҫʵ��һ����ʱ������
��ĳ����������һ���ı���ǩ
λ�������Զ�

�ı���ǩ��ʾ�ĸ�ʽ�� 00:00 �ֱ��ʾ ��:��


Ϊ��ʵ���������������Ҫ���µĹ���
1. ��ȡ���µ�ʱ��
2. ����ʱ����ʾ
3. ע������¼�, ͨ�����������ƶ�ʱ��



1, ��ȡ��ǰ��ʱ��ķ�������

currentTime()


// ����һ������, ������ǵ�ǰ��ʱ��, ��λΪ ��
// ��ô�´��ٵ�����������õ���ʱ���ȥ���ʱ�����ʱ���
// 1554705633

2, ��ʱ�������Ѿ�������Ĵ�������

3, �ο�����Ĵ���, ʵ��һ����ʱ��
��ʼ��ť��ʼ��ʱ����ʼ����ʱ����ʾ
��ͣ��ťֹͣ��ʱ������ʱ����ʾ
���ð�ťֹͣ��ʱ������ʱ��Ϊ 00:00

4. ����ʱ�������ı�, �� setText����
ע��������Ҫ����һ���ַ���
����Ҫ�� int ���͵�����ת��һ���ַ���, ֮ǰ����ҵ���ṩ intToString ����
�ṩ�� intToString Ҫ����������ֱ������0, �Լ��޸�, �� intToString ������ 0, ���� "0"


��˼·�ϵ�����, ����Ⱥ������
*/

typedef GuaScene SceneMain;
typedef GuaImage Clock;
typedef struct ClockDataStruct ClockData;
struct ClockDataStruct {
	int startTime;
	int seconds;
	bool run;
	TTF_Font *font;
};


int
currentTime() {
	time_t *t = NULL;
	int r = (int)time(t);
	return r;
}

char *
intToString(int n) {
	char *numnbers = "0123456789";
	int dividend = 1;
	int remainder = n % dividend;
	int length = 0;

	while (remainder != n) {
		dividend = dividend * 10;
		remainder = n % dividend;
		length = length + 1;
	}
	char *nStr = malloc(sizeof(char) * (length + 1));

	int n2 = n;
	dividend = 1;
	for (int i = length - 1; i >= 0; i--) {
		dividend = dividend * 10;
		remainder = n2 % dividend;
		int index = remainder * 10 / dividend;
		char c = *(numnbers + index);
		*(nStr + i) = c;

		n2 = n2 - remainder;
	}
	*(nStr + length) = '\0';
	return nStr;
}

static SDL_Texture *
GuaTextRenderTexture(SDL_Renderer *renderer, TTF_Font *font, const char *text, SDL_Color fontColor) {
	SDL_Surface *surface = TTF_RenderText_Blended(font, text, fontColor);
	SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, surface);
	SDL_FreeSurface(surface);

	return texture;
}

static void
setText(GuaLabel *self, char *text) {
	ClockData *data = self->data;
	TTF_Font *font = data->font;
	SDL_Color fontColor = { 255, 0, 0, 0, };
	SDL_Texture *textTexture = GuaTextRenderTexture(GuaGameRender(self->game), font, text, fontColor);

	if (self->texture != NULL) {
		SDL_DestroyTexture(self->texture);
	}
	self->texture = textTexture;
}

static void
update(GuaImage *self) {
	TTF_Init();
	char *fontPath = "resource/font/OpenSans-Regular.ttf";
	TTF_Font *font = TTF_OpenFont(fontPath, 34);

	int timenew = currentTime();
	//printf("new time is %d", timenew);
	ClockData *data = malloc(sizeof(ClockData));
	data->font = font;
	data->startTime = timenew;
	data->seconds = 0;
	data->run = false;

	self->data = data;
}

static void
setup(GuaImage *self) {
	TTF_Init();
	char *fontPath = "resource/font/OpenSans-Regular.ttf";
	TTF_Font *font = TTF_OpenFont(fontPath, 34);

	ClockData *data = malloc(sizeof(ClockData));
	data->font = font;
	data->startTime = currentTime();
	data->seconds = 0;
	data->run = false;

	self->data = data;

}

Clock *
ClockNew(GuaGame *game) {
	Clock *clock = GuaImageNew(game, "");
	setup(clock);
	setText(clock, "00:00");

	// dyp genius
	ClockData *clockdata;
	clockdata = clock->data;
	printf("starttime : %d", clockdata->startTime);

	clock->update = update;
	ClockData *clockdata2;
    clockdata2 = clock->data;
    printf("starttime2 : %d", clockdata2->startTime);
	setText(clock, "00:01");

	return clock;
}


SceneMain *
SceneMainNew(GuaGame *game) {
	// �½�����
	SceneMain *scene = GuaSceneNew(game);

	// ����һ�� clock1 ��ʱ��
	// ��һ�������Ǵ���� guagame
	// �ڶ��������Ǿ��������
	Clock *clock1 = ClockNew(game);

	// dyp test
	//int timetest = currentTime();
	//char *timestring = intToString(timetest);
	//setText(clock1, timestring);

	// ���� clock1 �ĳ����Լ� x, y ����
	GuaImageSetWidth(clock1, 100);
	GuaImageSetHeight(clock1, 40);
	GuaImageSetX(clock1, 300);
	GuaImageSetY(clock1, 400);

	// ʹ�� GuaSceneAddElement �� clock1 ��ӽ�����
	GuaSceneAddElement(scene, clock1);

	return scene;
}

int
main(int argc, char* argv[]) {
	// ͼƬ������
	ImageLoader *loader = ImageLoaderCreate();

	// ����һ�� guagame
	GuaGame *guaGame = GuaGameNew(loader);

	// �½�һ������
	GuaScene *scene = SceneMainNew(guaGame);

	// ����guagame, ��Ҫ���볡��
	GuaGameRunWithScene(guaGame, scene);

	return 0;
}
