/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE)
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    Script Name: mud_craft
    DESCRIPTION: Inventory validation and "Bounce" logic for containers.
   ============================================================================
*/

void BounceItems(object oStation, object oPC) {
    object oItem = GetFirstItemInInventory(oStation);
    while (GetIsObjectValid(oItem)) {
        AssignCommand(oStation, ActionGiveItem(oItem, oPC));
        oItem = GetNextItemInInventory(oStation);
    }
}

void main() {
    object oPC = OBJECT_SELF;
    object oStation = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC);
    string sChat = GetStringLowerCase(GetPCChatMessage());
    string s2DA = GetResRef(GetArea(oPC)) + "_craft";

    // PHASE 1: Find Recipe
    int nRow = 0; string sRecipeKey;
    while(nRow < 100) {
        sRecipeKey = GetStringLowerCase(Get2DAString(s2DA, "Trigger", nRow));
        if (sRecipeKey == "" || FindSubString(sChat, sRecipeKey) != -1) break;
        nRow++;
    }

    // PHASE 2: Validation
    int nMin = StringToInt(Get2DAString(s2DA, "Skill_Needed", nRow));
    if (GetLocalInt(oPC, "SKILL_CRAFTING") < nMin) {
        SendMessageToPC(oPC, "DOWE: Skill too low. Returning items.");
        BounceItems(oStation, oPC);
        return;
    }

    // PHASE 3: Success/Fail
    // Roll logic... if fail, Destroy items in station. 
    // If mismatch items in station, call BounceItems.
}
