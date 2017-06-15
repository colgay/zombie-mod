#if defined _ITEM_SMA
	#endinput
#endif
#define _ITEM_SMA

#define g_item.%0. g_item[Item_%0]

enum _:ItemData
{
	Array:Item_name,
	Array:Item_desc,
	Array:Item_class,
	Array:Item_pack,
	Item_size
};

new g_item[ItemData];

Item@Init()
{
	g_item.name. = ArrayCreate(32);
	g_item.desc. = ArrayCreate(64);
	g_item.class. = ArrayCreate(32);
	g_item.pack. = ArrayCreate(1);
	
	createItem("綠色草藥", "haha jai yooy jai", "herb_green", 3);
	createItem("紅色草藥", "i 5g this is what 7?", "herb_red", 2);
	createItem("藍色草藥", "can someone tell me what 7 is this?", "herb_blue", 2);
	createItem("急救藥物", "don't eat this if you are hungry, ha.", "firstaid", 1);
	createItem("子彈", "i have no gun, give me ammo have what 7 use?", "ammo", 3);
	createItem("OK仔的JJ", "ha so big wor ching", "okjai", 1);
	createItem("顯微鏡", "use this for ok jai jj", "zoom", 1);
}

stock createItem(const name[], const desc[], const class[], pack=1)
{
	ArrayPushString(g_item.name., name);
	ArrayPushString(g_item.desc., desc);
	ArrayPushString(g_item.class., class);
	ArrayPushCell(g_item.pack., pack);
	
	g_item.size.++;
	return g_item.size. - 1;
}

stock getItemName(index, string[], len)
{
	return ArrayGetString(g_item.name., index, string, len);
}

stock getItemDesc(index, string[], len)
{
	return ArrayGetString(g_item.desc., index, string, len);
}

stock getItemClass(index, string[], len)
{
	return ArrayGetString(g_item.class., index, string, len);
}

stock getItemPackSize(index)
{
	return ArrayGetCell(g_item.pack., index);
}

stock getItemCount()
{
	return g_item.size.;
}

stock getItemByClass(const class[])
{
	static string[32];
	
	for (new i = 0; i < g_item.size_; i++)
	{
		getItemClass(i, string, charsmax(string));
		
		if (equal(class, string))
			return i;
	}
	
	return -1;
}