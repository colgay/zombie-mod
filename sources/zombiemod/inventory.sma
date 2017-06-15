#if defined _INVENTORY_SMA
	#endinput
#endif
#define _INVENTORY_SMA

#define MAX_INVENTORY_SIZE 14

#define g_inventory[%0][$%1] g_inventory[%0][Inventory_%1]
#define g_menuInventory[%0][$%1] g_menuInventory[%0][InvMenu_%1]

enum _:InventoryData
{
	Array:Inventory_Item,
	Array:Inventory_Amount,
	Inventory_Size,
	Inventory_Max,
};

enum _:InventoryMenuData
{
	InvMenu_Page,
	InvMenu_Index
};

new g_inventory[MAX_CLIENTS+1][InventoryData];
new g_menuInventory[MAX_CLIENTS+1][InventoryMenuData];

new g_shopMenuIndex[MAX_CLIENTS+1];
new g_shopMenuAmount[MAX_CLIENTS+1];

Inventory@Init()
{
	for (new i = 1; i <= g_maxClients; i++)
	{
		g_inventory[i][$Item] = ArrayCreate(1);
		g_inventory[i][$Amount] = ArrayCreate(1);
		g_inventory[i][$Max] = MAX_INVENTORY_SIZE;
	}
	
	register_clcmd("inventory", "CmdInventory");
	register_clcmd("say /shop", "CmdSayShop");
	
	register_menucmd(register_menuid("Inventory Item Info"), 1023, "HandleInventoryItemMenu");
	register_menucmd(register_menuid("Buy Menu"), 1023, "HandleBuyMenu");
}

public CmdInventory(id)
{
	ShowInventoryMenu(id);
	return PLUGIN_HANDLED;
}

public CmdSayShop(id)
{
	ShowShopMenu(id);
	//return PLUGIN_HANDLED;
}

Inventory@Disconnect(id)
{
	clearInventory(id);
	g_inventory[id][$Max] = MAX_INVENTORY_SIZE;
}

public ShowInventoryMenu(id)
{
	new menu = menu_create("物品欄", "HandleInventoryMenu");
	
	static text[64], name[32];
	static item;
	
	for (new i = 0; i < g_inventory[id][$Size]; i++)
	{
		item = getInventoryItem(id, i);
		
		if (item == NULL)
		{
			formatex(text, charsmax(text), "\\d--- (-/-)");
		}
		else
		{
			getItemName(item, name, charsmax(name));
			formatex(text, charsmax(text), "%s \\y(%d/%d)", name, getInventoryAmount(id, i), getItemPackSize(item));
		}
		
		menu_additem(menu, text);
	}
	
	for (new i = g_inventory[id][$Size]; i < g_inventory[id][$Max]; i++)
	{
		menu_additem(menu, "\\d--- (-/-)");
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\\y");
	menu_display(id, menu, g_menuInventory[id][$Page]);
}

public HandleInventoryMenu(id, menu, item)
{
	if (is_user_connected(id))
	{
		static dummy;
		player_menu_info(id, dummy, dummy, g_menuInventory[id][$Page]);
	}
	
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	static info[10], dummy;
	menu_item_getinfo(menu, item, dummy, info, charsmax(info), _, _, dummy);
	menu_destroy(menu);
	
	new itemId = getInventoryItem(id, item);
	if (itemId != NULL)
	{
		ShowInventoryItemMenu(id, item);
	}
}

ShowInventoryItemMenu(id, slot)
{
	new item = getInventoryItem(id, slot);
	new amount = getInventoryAmount(id, slot);
	
	static name[32], desc[64];
	getItemName(item, name, charsmax(name));
	getItemDesc(item, desc, charsmax(desc));
	
	static menu[512], len;
	len = formatex(menu, charsmax(menu), "\\y物品資訊 #%d\n\n", slot);
	
	len += formatex(menu[len], 511-len, "\\w名稱: \\y%s\n", name);
	len += formatex(menu[len], 511-len, "\\w數量: \\y(%d/%d)\n", amount, getItemPackSize(item));
	len += formatex(menu[len], 511-len, "\\w描述:\n%s\n\n", desc);
	
	len += formatex(menu[len], 511-len, "\\y1. \\w使用\n");
	len += formatex(menu[len], 511-len, "\\y2. \\w丟棄\n");
	len += formatex(menu[len], 511-len, "\\y3. \\w丟棄 %d 個\n\n", amount);
	
	len += formatex(menu[len], 511-len, "\\y0. \\w返回");
	
	new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0;
	
	show_menu(id, keys, menu, -1, "Inventory Item Info");
	
	g_menuInventory[id][$Index] = slot;
}

public HandleInventoryItemMenu(id, key)
{
	if (key == 9)
	{
		ShowInventoryMenu(id);
		return;
	}
	
	new slot = g_menuInventory[id][$Index];
	new item = getInventoryItem(id, slot);
	
	if (item == NULL)
	{
		client_print(id, print_center, "無效物品");
		ShowInventoryMenu(id);
		return;
	}
	
	static name[32];
	getItemName(item, name, charsmax(name));
	
	switch (key)
	{
		case 0:
		{
			useInventoryItem(id, slot);
			client_print(id, print_chat, "你使用了 %s", name);
		}
		case 1:
		{
			dropInventoryItem(id, slot, 1);
			client_print(id, print_chat, "你丟棄了 %s", name);
		}
		case 2:
		{
			new amount = getInventoryAmount(id, slot);
			
			dropInventoryItem(id, slot, amount);
			client_print(id, print_chat, "你丟棄了 %s (%d 個)", name, amount);
		}
	}
}

ShowShopMenu(id)
{
	new menu = menu_create("商店", "HandleShopMenu");
	
	static name[32];
	
	new size = getItemCount();
	
	for (new i = 0; i < size; i++)
	{
		getItemName(i, name, charsmax(name));
		
		menu_additem(menu, name);
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\\y");
	menu_display(id, menu);
}

public HandleShopMenu(id, menu, item)
{
	menu_destroy(menu);
	
	if (item == MENU_EXIT)
		return;
	
	g_shopMenuAmount[id] = 1;
	ShowBuyMenu(id, item);
}

ShowBuyMenu(id, item)
{
	static name[32];
	getItemName(item, name, charsmax(name));
	
	static menu[512], len;
	len = formatex(menu, charsmax(menu), "\\y你想購買多少個 \\w%s \\y? (\\w%d \\y個)\n\n", name, g_shopMenuAmount[id]);
	
	len += formatex(menu[len], 511-len, "\\y1. \\w-10\n");
	len += formatex(menu[len], 511-len, "\\y2. \\w-5\n");
	len += formatex(menu[len], 511-len, "\\y3. \\w-2\n");
	len += formatex(menu[len], 511-len, "\\y4. \\w-1\n");
	len += formatex(menu[len], 511-len, "\\y5. \\w+1\n");
	len += formatex(menu[len], 511-len, "\\y6. \\w+2\n");
	len += formatex(menu[len], 511-len, "\\y7. \\w+5\n");
	len += formatex(menu[len], 511-len, "\\y8. \\w+10\n\n");
	
	len += formatex(menu[len], 511-len, "\\y9. \\w購買\n");
	len += formatex(menu[len], 511-len, "\\y0. \\w返回");
	
	new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;
	
	show_menu(id, keys, menu, -1, "Buy Menu");
	
	g_shopMenuIndex[id] = item;
}

public HandleBuyMenu(id, key)
{
	if (key == 9)
	{
		ShowShopMenu(id);
		return;
	}

	new item = g_shopMenuIndex[id];
	if (key == 8)
	{
		new amount = g_shopMenuAmount[id];
		giveInventoryItem(id, item, amount);
		
		static name[32];
		getItemName(item, name, charsmax(name));
		
		client_print(id, print_chat, "你購買了 %s (%d 個)", name, amount);
	}
	else
	{
		switch (key)
		{
			case 0: g_shopMenuAmount[id] -= 10;
			case 1: g_shopMenuAmount[id] -= 5;
			case 2: g_shopMenuAmount[id] -= 2;
			case 3: g_shopMenuAmount[id] -= 1;
			case 4: g_shopMenuAmount[id] += 1;
			case 5: g_shopMenuAmount[id] += 2;
			case 6: g_shopMenuAmount[id] += 5;
			case 7: g_shopMenuAmount[id] += 10;
		}
		
		g_shopMenuAmount[id] = clamp(g_shopMenuAmount[id], 1, 50);
		ShowBuyMenu(id, item);
	}
}

stock giveInventoryItem(id, item, amount)
{
	new count = amount;
	new pack = getItemPackSize(item);
	new size = g_inventory[id][$Size];
	new item2, amount2;
	new i = 0;
 	new num;
	
	while (count > 0 && i < size)
	{
		item2 = getInventoryItem(id, i);
		
		if (item2 == item)
		{
			amount2 = getInventoryAmount(id, i);
			if (amount2 < pack)
			{
				num = min(count, pack - amount2);
				ArraySetCell(g_inventory[id][$Amount], i, amount2 + num);
				count -= num;
			}
		}
		else if (item2 == NULL)
		{
			num = min(count, pack);
			ArraySetCell(g_inventory[id][$Item], i, item);
			ArraySetCell(g_inventory[id][$Amount], i, num);
			count -= num;
		}
		
		i++;
	}
	
	while (count > 0 && size < g_inventory[id][$Max])
	{
		num = min(count, pack);
		ArrayPushCell(g_inventory[id][$Item], item);
		ArrayPushCell(g_inventory[id][$Amount], num);
		count -= num;
		size++;
	}
	
	g_inventory[id][$Size] = ArraySize(g_inventory[id][$Item]);
}

stock useInventoryItem(id, slot)
{
	new amount = getInventoryAmount(id, slot);
	if (amount > 1)
	{
		ArraySetCell(g_inventory[id][$Amount], slot, amount - 1);
	}
	else
	{
		setInventoryItem(id, slot, NULL, 0);
	}
}

stock dropInventoryItem(id, slot, amount)
{
	new stocks = getInventoryAmount(id, slot);
	if (stocks - amount > 0)
	{
		ArraySetCell(g_inventory[id][$Amount], slot, stocks - amount);
	}
	else
	{
		setInventoryItem(id, slot, NULL, 0);
	}
}

stock clearInventory(id)
{
	ArrayClear(g_inventory[id][$Item]);
	ArrayClear(g_inventory[id][$Amount]);
	g_inventory[id][$Size] = 0;
}

stock getInventoryItem(id, slot)
{
	if (slot >= g_inventory[id][$Size])
		return NULL;
	
	return ArrayGetCell(g_inventory[id][$Item], slot);
}

stock getInventoryAmount(id, slot)
{
	if (slot >= g_inventory[id][$Size])
		return NULL;
	
	return ArrayGetCell(g_inventory[id][$Amount], slot);
}

stock setInventoryItem(id, slot, item, amount)
{
	new size = g_inventory[id][$Size];
	if (slot >= size)
	{
		if (item == NULL)
			return;
		
		for (new i = size; i < (slot - 1); i++)
		{
			ArrayPushCell(g_inventory[id][$Item], NULL);
			ArrayPushCell(g_inventory[id][$Amount], 0);
		}
		
		ArrayPushCell(g_inventory[id][$Item], item);
		ArrayPushCell(g_inventory[id][$Amount], min(amount, getItemPackSize(item)));
		
		g_inventory[id][$Size] = ArraySize(g_inventory[id][$Item]);
	}
	else
	{
		ArraySetCell(g_inventory[id][$Item], slot, item);
		ArraySetCell(g_inventory[id][$Amount], slot, amount);
		
		if (item == NULL && size > 0)
		{
			for (new i = (size - 1); i >= 0; i--)
			{
				if (getInventoryItem(id, i) != NULL)
					break;
				
				ArrayDeleteItem(g_inventory[id][$Item], i);
				ArrayDeleteItem(g_inventory[id][$Amount], i);
			}
			
			g_inventory[id][$Size] = ArraySize(g_inventory[id][$Item]);
		}
	}
}