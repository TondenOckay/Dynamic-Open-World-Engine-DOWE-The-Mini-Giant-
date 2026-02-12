/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: mud_inc
    
    PILLARS: 
    1. Independent Mini-Servers Architecture 
    2. Phase-Staggered Performance Optimization 
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION: 
    Master utility library for the MUD engine. Handles high-speed string 
    tokenization, inventory validation, and item consumption. 
    Integrates specifically with the 'area_debug' reporting system.
   ============================================================================
*/

// --- PHASE 1: AREA_DEBUG INTEGRATION ---

// Logic: Routes all system messages to the area_debug script.
// Uses local variables on the Area to toggle visibility for players/DMs.
void DOWE_Report(object oPC, string sMessage) {
    object oArea = GetArea(oPC);
    // Check if the Master Debug Toggle is on for this area
    if (GetLocalInt(oArea, "DOWE_DEBUG_ACTIVE") == TRUE) {
        // Store the message on the PC for the area_debug script to pick up
        SetLocalString(oPC, "LAST_DEBUG_MSG", sMessage);
        // Phase-Staggered call to the debug processor
        ExecuteScript("area_debug", oPC);
    }
}

// --- PHASE 2: STRING TOKENIZATION (THE CHOPS) ---

// STAGGERED LOGIC: Extracts tokens from comma-separated 2DA strings.
string GetTokenByCommata(string sFull, int nToken) {
    int nStart = 0; int nCount = 0;
    int nEnd = FindSubString(sFull, ",");
    if (nEnd == -1) return (nToken == 0) ? sFull : "";
    while (nCount < nToken) {
        nStart = nEnd + 1;
        nEnd = FindSubString(sFull, ",", nStart);
        nCount++;
        if (nEnd == -1 && nCount == nToken) 
            return GetSubString(sFull, nStart, GetStringLength(sFull) - nStart);
        if (nEnd == -1) return "";
    }
    return GetSubString(sFull, nStart, nEnd - nStart);
}

// --- PHASE 3: RESOURCE MANAGEMENT (ZERO-WASTE) ---

// TOTAL RESOURCE MANAGEMENT: Validates if PC possesses all items in a list.
int GetHasAllTokens(object oPC, string sList) {
    if (sList == "****" || sList == "" || sList == "0") return TRUE;
    int i = 0; string sItem = GetTokenByCommata(sList, i);
    while (sItem != "") {
        string sTrim = GetStringTrim(sItem);
        if (!GetIsObjectValid(GetItemPossessedBy(oPC, sTrim))) {
            DOWE_Report(oPC, "MISSING_REQ: " + sTrim);
            return FALSE;
        }
        i++; sItem = GetTokenByCommata(sList, i);
    }
    return TRUE;
}

// ZERO-WASTE: Spawns multiple items into oTarget's inventory.
void CreateAllTokens(string sList, object oTarget) {
    if (sList == "****" || sList == "" || sList == "0") return;
    int i = 0; string sItem = GetTokenByCommata(sList, i);
    while (sItem != "") {
        string sTrim = GetStringTrim(sItem);
        if (sTrim != "") {
            CreateItemOnObject(sTrim, oTarget);
            DOWE_Report(oTarget, "ITEM_CREATED: " + sTrim);
        }
        i++; sItem = GetTokenByCommata(sList, i);
    }
}

// PILLAR 3: Consumes (Destroys) all items in a list from oTarget.
void ConsumeAllTokens(object oTarget, string sList) {
    if (sList == "****" || sList == "" || sList == "0") return;
    int i = 0; string sItem = GetTokenByCommata(sList, i);
    while (sItem != "") {
        string sTrim = GetStringTrim(sItem);
        object oInv = GetItemPossessedBy(oTarget, sTrim);
        if (GetIsObjectValid(oInv)) {
            DestroyObject(oInv);
            DOWE_Report(oTarget, "ITEM_CONSUMED: " + sTrim);
        }
        i++; sItem = GetTokenByCommata(sList, i);
    }
}
