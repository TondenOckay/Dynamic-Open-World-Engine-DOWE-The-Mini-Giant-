/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: enc_gps
    PILLARS: 
        1. Independent Mini-Servers Architecture 
        2. Phase-Staggered Performance Optimization 
        3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    The "Eye in the Sky" spatial manager. Manages the creature list, 
    checks player proximity for combat, and handles 40% encounter rolls. 
    Maintains O(1) efficiency by using the VIP Registry.
   ============================================================================
*/

// --- 2DA REFERENCE NOTES ---
// // enc_locations.2da - X,Y,Z, ResRef, and Pathing data.
// // enc_tables.2da - Surface material to ResRef mapping.

void main()
{
    // PHASE 1: INITIALIZATION & VALIDATION
    object oArea = OBJECT_SELF;
    int nPop = GetLocalInt(oArea, "MG_POPULATION");

    // Zero-Waste Check: If no players are registered, kill the logic.
    if (nPop <= 0) return;

    // PHASE 2: CREATURE LIST MAINTENANCE (Staggered)
    // We clean up the list to remove dead or invalid IDs to keep the list lean.
    int nTotalEnc = GetLocalInt(oArea, "MG_ENC_COUNT");
    int i;
    for (i = 1; i <= nTotalEnc; i++)
    {
        float fStagger = i * 0.05; // 0.05s per creature to flatten CPU spike
        DelayCommand(fStagger, SetLocalInt(oArea, "MG_CLEANUP_IDX", i));
        DelayCommand(fStagger + 0.01, ExecuteScript("enc_list_clean", oArea));
    }

    // PHASE 3: PLAYER SPATIAL SCAN (The Heart of the GPS)
    // We iterate through the VIP slots 1-100.
    for (i = 1; i <= 100; i++)
    {
        object oPC = GetLocalObject(oArea, "MG_VIP_OBJ_" + IntToString(i));
        
        // Skip empty slots or DMs.
        if (!GetIsObjectValid(oPC) || GetIsDM(oPC)) continue;

        // Spread the processing of each player out by 0.5 seconds.
        float fPlayerStagger = i * 0.5;

        // CHECK A: Is player already in combat?
        if (GetIsInCombat(oPC)) 
        {
             if (GetLocalInt(oArea, "MG_DEBUG_ON"))
             {
                DelayCommand(fPlayerStagger, SetLocalString(oArea, "MG_DEBUG_MSG", "GPS: " + GetName(oPC) + " in combat. Skipping."));
                DelayCommand(fPlayerStagger + 0.01, ExecuteScript("area_debug", oArea));
             }
             continue;
        }

        // CHECK B: 40% Encounter Roll
        if (Random(100) < 40)
        {
            // Set the target for the Switchboard packet.
            DelayCommand(fPlayerStagger, SetLocalObject(oArea, "MG_SW_TARGET", oPC));
            DelayCommand(fPlayerStagger, SetLocalInt(oArea, "MG_SW_EVENT", 500)); // 500 = Trigger Spawn Phase
            
            // Execute the Spawn Logic through the Switchboard.
            DelayCommand(fPlayerStagger + 0.05, ExecuteScript("area_switchboard", oArea));
        }
    }
}
