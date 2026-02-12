/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
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

#include "mud_inc"

// PHASE-STAGGERED: Handles simulated movement points for baked-in entities.
void ExecuteBakedWalk(object oPC, string sPoints) {
    if (sPoints == "****" || sPoints == "") return;
    int i = 0;
    string sWP = GetTokenByCommata(sPoints, i);
    float fDelay = 1.0;
    while (sWP != "") {
        // Staggered Notification to PC for Zero-Waste world simulation.
        DelayCommand(fDelay, SendMessageToPC(oPC, ">> The entity moves toward waypoint: " + sWP));
        fDelay += 2.0;
        i++;
        sWP = GetTokenByCommata(sPoints, i);
    }
}

void main() {
    // PHASE 1: Data Acquisition & Setup
    object oPC = OBJECT_SELF;
    string sChat = GetStringLowerCase(GetPCChatMessage());
    string s2DA = GetResRef(GetArea(oPC)) + "_npc";
    int nRow = 0;

    // PHASE 2: Zero-Waste Scrutiny Loop
    while (nRow < 255) {
        string sName = Get2DAString(s2DA, "NPC_Name", nRow);
        if (sName == "") break; 

        string sKey = GetStringLowerCase(Get2DAString(s2DA, "Trigger", nRow));
        if (FindSubString(sChat, sKey) != -1) {
            
            // Distance Calculation (Proximity validation)
            vector vL;
            vL.x = StringToFloat(Get2DAString(s2DA, "Loc_X", nRow));
            vL.y = StringToFloat(Get2DAString(s2DA, "Loc_Y", nRow));
            vL.z = StringToFloat(Get2DAString(s2DA, "Loc_Z", nRow));
            
            if (GetDistanceBetweenLocations(GetLocation(oPC), Location(GetArea(oPC), vL, 0.0)) <= 5.0) {
                
                // PHASE 3: Faction & Item Validation
                int nFactReq = StringToInt(Get2DAString(s2DA, "FactionReq", nRow));
                string sItemReq = Get2DAString(s2DA, "NeededItems", nRow);

                // Reputation Gate
                if (nFactReq != 0 && GetStandardFactionReputation(nFactReq, oPC) < 50) {
                    SendMessageToPC(oPC, sName + ": I do not trust you enough to speak.");
                    return;
                }

                // Inventory Validation via mud_inc
                if (!GetHasAllTokens(oPC, sItemReq)) {
                    SendMessageToPC(oPC, sName + ": You lack the materials required.");
                    return;
                }

                // PHASE 4: Staggered Execution
                SendMessageToPC(oPC, sName + ": " + Get2DAString(s2DA, "Response", nRow));
                CreateAllTokens(Get2DAString(s2DA, "GiveItems", nRow), oPC);
                ExecuteBakedWalk(oPC, Get2DAString(s2DA, "WalkPoints", nRow));
                
                // Store Logic Integration
                string sShop = Get2DAString(s2DA, "ShopTag", nRow);
                if (sShop != "****") {
                    object oStore = GetNearestObjectByTag(sShop);
                    if (GetIsObjectValid(oStore)) OpenStore(oStore, oPC);
                }
                return; 
            }
        }
        nRow++;
    }
}
