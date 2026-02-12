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
    Hybrid Engine: Interactions are triggered via physical NPCs (2m range) 
    while logic, rewards, and waypoints are stored in 2DAs. 
    Includes a 10m 'Zone Active' throttle to save CPU.
   ============================================================================
*/

#include "mud_inc"

// PHASE-STAGGERED: Handles simulated movement points for baked-in entities.
// Note: Reports movement context to the player since the pathing is baked logic.
void ExecuteBakedWalk(object oPC, string sPoints) {
    if (sPoints == "****" || sPoints == "") return;
    int i = 0;
    string sWP = GetTokenByCommata(sPoints, i);
    float fDelay = 1.0;
    while (sWP != "") {
        DelayCommand(fDelay, SendMessageToPC(oPC, ">> The entity moves toward waypoint: " + sWP));
        fDelay += 2.0;
        i++;
        sWP = GetTokenByCommata(sPoints, i);
    }
}

void main() {
    // PHASE 1: Data Acquisition & CPU Throttling
    object oPC = OBJECT_SELF;
    object oTarget = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_NOT_PC);
    
    // GOLD STANDARD FIX: If no NPC is within 10m, terminate script immediately.
    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > 10.0) return;

    string sChat = GetStringLowerCase(GetPCChatMessage());
    string s2DA = GetResRef(GetArea(oPC)) + "_npc";
    int nRow = 0;

    // PHASE 2: Phase-Staggered 2DA Scrutiny
    while (nRow < 255) {
        // We use 'NPC_Tag' to match the physical NPC clicked/spoken to
        string sTag = Get2DAString(s2DA, "NPC_Tag", nRow);
        if (sTag == "") break; 

        if (GetTag(oTarget) == sTag) {
            // PILLAR 2: Interaction Proximity Gate (2.0 meters)
            if (GetDistanceBetween(oPC, oTarget) <= 2.0) {
                string sKey = GetStringLowerCase(Get2DAString(s2DA, "Trigger", nRow));
                
                if (FindSubString(sChat, sKey) != -1) {
                    // PHASE 3: Faction & Item Validation
                    int nFactReq = StringToInt(Get2DAString(s2DA, "FactionReq", nRow));
                    string sItemReq = Get2DAString(s2DA, "NeededItems", nRow);

                    // Reputation Validation
                    if (nFactReq != 0 && GetStandardFactionReputation(nFactReq, oPC) < 50) {
                        SendMessageToPC(oPC, GetName(oTarget) + ": I do not trust you enough to speak.");
                        DOWE_Report(oPC, "FACTION_FAIL: " + sTag);
                        return;
                    }

                    // Inventory Validation
                    if (!GetHasAllTokens(oPC, sItemReq)) {
                        SendMessageToPC(oPC, GetName(oTarget) + ": You lack the materials required.");
                        DOWE_Report(oPC, "ITEM_FAIL: Missing " + sItemReq);
                        return;
                    }

                    // PHASE 4: Execution (Staggered rewards and movement)
                    SendMessageToPC(oPC, GetName(oTarget) + ": " + Get2DAString(s2DA, "Response", nRow));
                    
                    // PILLAR 3: Consume materials and grant rewards
                    ConsumeAllTokens(oPC, sItemReq);
                    CreateAllTokens(Get2DAString(s2DA, "GiveItems", nRow), oPC);
                    
                    // Trigger Baked Waypoints
                    ExecuteBakedWalk(oPC, Get2DAString(s2DA, "WalkPoints", nRow));
                    
                    // Store Check
                    string sShop = Get2DAString(s2DA, "ShopTag", nRow);
                    if (sShop != "****") {
                        object oStore = GetNearestObjectByTag(sShop);
                        if (GetIsObjectValid(oStore)) OpenStore(oStore, oPC);
                    }
                    return; 
                }
            }
        }
        nRow++;
    }
}
