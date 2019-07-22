 #include <stdio.h>
#include "guagame/gua_game.h"
#include "guagame/utils.h"
#include "guagame/gua_type.h"
#include "guagame/gua_scene.h"
#include "guagame/gua_label.h"
#include <time.h>
#define log(...) printf(__VA_ARGS__);


/*
本项目需要实现一个计时器程序
你的程序界面上有一个文本标签
位置排列自定

文本标签显示的格式是 00:00 分别表示 分:秒


为了实现这个程序我们需要以下的功能
1. 获取当下的时间
2. 更新时间显示
3. 注册键盘事件, 通过按键来控制定时器



1, 获取当前的时间的方法如下

currentTime()


// 返回一个整数, 代表的是当前的时间, 单位为 秒
// 那么下次再调用这个函数得到的时间减去这个时间就是时间差
// 1554705633

2, 定时器例子已经在下面的代码中了

3, 参考下面的代码, 实现一个计时器
开始按钮开始计时并开始更新时间显示
暂停按钮停止计时并定格时间显示
重置按钮停止计时并重置时间为 00:00

4. 给定时器设置文本, 用 setText函数
注意这里需要传入一个字符串
所以要把 int 类型的数字转成一个字符串, 之前的作业有提供 intToString 函数
提供的 intToString 要求输入的数字必须大于0, 自己修改, 让 intToString 能输入 0, 返回 "0"


有思路上的问题, 请在群内讨论
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
	// 新建场景
	SceneMain *scene = GuaSceneNew(game);

	// 创建一个 clock1 计时器
	// 第一个参数是传入的 guagame
	// 第二个参数是具体的文字
	Clock *clock1 = ClockNew(game);

	// dyp test
	//int timetest = currentTime();
	//char *timestring = intToString(timetest);
	//setText(clock1, timestring);

	// 设置 clock1 的长宽以及 x, y 坐标
	GuaImageSetWidth(clock1, 100);
	GuaImageSetHeight(clock1, 40);
	GuaImageSetX(clock1, 300);
	GuaImageSetY(clock1, 400);

	// 使用 GuaSceneAddElement 把 clock1 添加进场景
	GuaSceneAddElement(scene, clock1);

	return scene;
}

int
main(int argc, char* argv[]) {
	// 图片载入器
	ImageLoader *loader = ImageLoaderCreate();

	// 创建一个 guagame
	GuaGame *guaGame = GuaGameNew(loader);

	// 新建一个场景
	GuaScene *scene = SceneMainNew(guaGame);

	// 运行guagame, 需要传入场景
	GuaGameRunWithScene(guaGame, scene);

	return 0;
}
