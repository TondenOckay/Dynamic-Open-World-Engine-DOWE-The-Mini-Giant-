/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE)
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: mud_npc
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Handles Baked-in NPCs/Objects. Supports comma-separated item requirements,
    faction checks, shop triggers, and simulated movement points.
   ============================================================================
*/

#include #include "mud_inc"

// Logic: Handles the simulated walking points from the 2DA column
void ExecuteBakedWalk(object oPC, string sPoints) {
    if (sPoints == "****" || sPoints == "") return;
    
    int i = 0;
    string sWP = GetTokenByCommata(sPoints, i);
    float fDelay = 1.0;
    
    while (sWP != "") {
        // Logic: Send a debug or visual cue that the 'baked' NPC is moving
        // Since the NPC is baked, we notify the PC of the movement context.
        DelayCommand(fDelay, SendMessageToPC(oPC, ">> The entity moves toward waypoint: " + sWP));
        fDelay += 2.0;
        i++;
        sWP = GetTokenByCommata(sPoints, i);
    }
}

void main() {
    // PHASE 1: Data Acquisition
    object oPC = OBJECT_SELF;
    string sChat = GetStringLowerCase(GetPCChatMessage());
    string s2DA = GetResRef(GetArea(oPC)) + "_npc";
    int nRow = 0;

    // PHASE 2: Zero-Waste 2DA Processing
    while (nRow < 255) {
        string sName = Get2DAString(s2DA, "NPC_Name", nRow);
        if (sName == "") break; 

        // Keyword Search (Case Insensitive / Sentence Detection)
        string sKey = GetStringLowerCase(Get2DAString(s2DA, "Trigger", nRow));
        if (FindSubString(sChat, sKey) != -1) {
            
            // Distance Check (Proximity to Baked Coordinates)
            vector vL;
            vL.x = StringToFloat(Get2DAString(s2DA, "Loc_X", nRow));
            vL.y = StringToFloat(Get2DAString(s2DA, "Loc_Y", nRow));
            vL.z = StringToFloat(Get2DAString(s2DA, "Loc_Z", nRow));
            
            if (GetDistanceBetweenLocations(GetLocation(oPC), Location(GetArea(oPC), vL, 0.0)) <= 5.0) {
                
                // PHASE 3: Faction & Item Validation
                int nFactReq = StringToInt(Get2DAString(s2DA, "FactionReq", nRow));
                string sItemReq = Get2DAString(s2DA, "NeededItems", nRow);

                // Faction Check
                // Note: Standard NWN Factions (0=PC, 1=Hostile, 2=Commoner, 3=Merchant)
                // Adjust this logic if using custom DOWE Faction IDs.
                if (nFactReq != 0 && GetStandardFactionReputation(nFactReq, oPC) < 50) {
                    SendMessageToPC(oPC, sName + ": I do not trust your kind enough to speak.");
                    return;
                }

                // Multi-Item Requirement Check (via dowe_string_inc)
                if (!GetHasAllTokens(oPC, sItemReq)) {
                    SendMessageToPC(oPC, sName + ": You lack the materials ("+sItemReq+") I require.");
                    return;
                }

                // PHASE 4: Execution (Response, Rewards, Movement, Shops)
                SendMessageToPC(oPC, sName + ": " + Get2DAString(s2DA, "Response", nRow));
                
                // Give Multi-Item Rewards
                CreateAllTokens(Get2DAString(s2DA, "GiveItems", nRow), oPC);
                
                // Trigger Movement Points (Staggered)
                ExecuteBakedWalk(oPC, Get2DAString(s2DA, "WalkPoints", nRow));
                
                // Open Shop if tag exists
                string sShop = Get2DAString(s2DA, "ShopTag", nRow);
                if (sShop != "****") {
                    object oStore = GetNearestObjectByTag(sShop);
                    if (GetIsObjectValid(oStore)) OpenStore(oStore, oPC);
                }
                
                return; // Match found and executed.
            }
        }
        nRow++;
    }
}
