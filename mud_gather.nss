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
    Handles resource extraction, tool validation, and skill-based success rolls.
   ============================================================================
*/

#include "mud_inc"

void main() {
    // PHASE 1: Scoping
    object oPC = OBJECT_SELF;
    string sChat = GetStringLowerCase(GetPCChatMessage());
    string s2DA = GetResRef(GetArea(oPC)) + "_gather";
    int nRow = 0;

    // PHASE 2: Phase-Staggered Scanning
    while (nRow < 100) {
        string sKey = GetStringLowerCase(Get2DAString(s2DA, "Trigger", nRow));
        if (sKey == "") break;

        if (FindSubString(sChat, sKey) != -1) {
            // PHASE 3: Mathematical & Inventory Validation
            int nMin = StringToInt(Get2DAString(s2DA, "MinSkill", nRow));
            int nBase = StringToInt(Get2DAString(s2DA, "BaseChance", nRow));
            int nPCLevel = GetLocalInt(oPC, "SKILL_GATHER");
            string sTool = Get2DAString(s2DA, "ToolReq", nRow);

            // Skill Check
            if (nPCLevel < nMin) {
                SendMessageToPC(oPC, "DOWE: Skill level " + IntToString(nMin) + " required.");
                return;
            }

            // Tool Requirement Check
            if (sTool != "****" && !GetIsObjectValid(GetItemPossessedBy(oPC, sTool))) {
                SendMessageToPC(oPC, "DOWE: Required tool (" + sTool + ") not found.");
                return;
            }

            // PHASE 4: The 10% Skill Gain Roll (Gold Standard Pillar)
            if (d100() <= 10) {
                SetLocalInt(oPC, "SKILL_GATHER", nPCLevel + 1);
                SendMessageToPC(oPC, "DOWE: Gathering skill increased to " + IntToString(nPCLevel + 1));
            }

            // Success Roll (+5% per point above min)
            int nChance = nBase + ((nPCLevel - nMin) * 5);
            if (d100() <= nChance) {
                SendMessageToPC(oPC, Get2DAString(s2DA, "Response", nRow));
                CreateAllTokens(Get2DAString(s2DA, "GiveItems", nRow), oPC);
            } else {
                SendMessageToPC(oPC, "DOWE: Harvesting attempt failed.");
            }
            return;
        }
        nRow++;
    }
}
