/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: mud_gather
    
    PILLARS: 
    1. Independent Mini-Servers Architecture 
    2. Phase-Staggered Performance Optimization 
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION: 
    Handles resource extraction from baked coordinates. Validates player proximity 
    to invisible nodes (2m), tool requirements, and skill progression.
   ============================================================================
*/

#include "mud_inc"

void main() {
    // PHASE 1: Data Acquisition
    object oPC = OBJECT_SELF;
    string sChat = GetStringLowerCase(GetPCChatMessage());
    string s2DA = GetResRef(GetArea(oPC)) + "_gather";
    int nRow = 0;

    // PHASE 2: Zero-Waste Scrutiny Loop
    while (nRow < 100) {
        string sKey = GetStringLowerCase(Get2DAString(s2DA, "Trigger", nRow));
        if (sKey == "") break;

        if (FindSubString(sChat, sKey) != -1) {
            // PHASE 3: Baked Proximity Validation
            vector vL;
            vL.x = StringToFloat(Get2DAString(s2DA, "Loc_X", nRow));
            vL.y = StringToFloat(Get2DAString(s2DA, "Loc_Y", nRow));
            vL.z = StringToFloat(Get2DAString(s2DA, "Loc_Z", nRow));
            location lNode = Location(GetArea(oPC), vL, 0.0);

            // PILLAR 2: Check for 2.0m Proximity to the baked coordinate node
            if (GetDistanceBetweenLocations(GetLocation(oPC), lNode) <= 2.0) {
                
                int nMin = StringToInt(Get2DAString(s2DA, "MinSkill", nRow));
                int nBase = StringToInt(Get2DAString(s2DA, "BaseChance", nRow));
                int nPCLevel = GetLocalInt(oPC, "SKILL_GATHER");
                string sTool = Get2DAString(s2DA, "ToolReq", nRow);

                // Skill Gate
                if (nPCLevel < nMin) {
                    SendMessageToPC(oPC, "DOWE: Gathering skill too low. Required: " + IntToString(nMin));
                    return;
                }

                // Tool Check
                if (sTool != "****" && !GetIsObjectValid(GetItemPossessedBy(oPC, sTool))) {
                    SendMessageToPC(oPC, "DOWE: Required tool (" + sTool + ") not found.");
                    DOWE_Report(oPC, "TOOL_FAIL: Missing " + sTool);
                    return;
                }

                // PHASE 4: 10% Skill Gain Roll
                if (d100() <= 10) {
                    SetLocalInt(oPC, "SKILL_GATHER", nPCLevel + 1);
                    SendMessageToPC(oPC, "DOWE: Gathering skill increased to " + IntToString(nPCLevel + 1));
                }

                // Success Calculation (+5% bonus per point above min)
                int nChance = nBase + ((nPCLevel - nMin) * 5);
                if (d100() <= nChance) {
                    SendMessageToPC(oPC, Get2DAString(s2DA, "Response", nRow));
                    CreateAllTokens(Get2DAString(s2DA, "GiveItems", nRow), oPC);
                    DOWE_Report(oPC, "GATHER_SUCCESS at row " + IntToString(nRow));
                } else {
                    SendMessageToPC(oPC, "DOWE: Harvesting attempt failed.");
                }
                return;
            }
        }
        nRow++;
    }
}
