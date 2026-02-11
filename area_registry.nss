/* ============================================================================
    Project Name: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_registry
    PILLARS: 
        1. Independent Mini-Servers Architecture 
        2. Phase-Staggered Performance Optimization 
        3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Tracks players on the Mini-Server. Assigns VIP slots, records CD Keys,
    and fills empty "voids" in the list left by players who exited or crashed.
   ============================================================================
*/

// --- 2DA REFERENCE NOTES ---
// // No 2DA references required for registry indexing.

void main()
{
    // PHASE 1: DATA RETRIEVAL
    object oArea = OBJECT_SELF;
    object oPC = GetLocalObject(oArea, "MG_SW_TARGET");
    
    // Safety check: Ensure we have a valid target from the Switchboard.
    if (!GetIsObjectValid(oPC)) return;

    string sCDKey = GetPCPublicCDKey(oPC);
    int nMaxSlots = 100; // Define max capacity for this mini-server slot array.
    int nSlot = 1;
    int nTargetSlot = 0;

    // PHASE 2: VOID DETECTION & SLOT ASSIGNMENT (Staggered Scan)
    // We look for the first available empty string in our local variable list.
    while (nSlot <= nMaxSlots)
    {
        string sExistingKey = GetLocalString(oArea, "MG_VIP_KEY_" + IntToString(nSlot));
        
        // If the slot is empty ("") or the player is already here (re-log safety).
        if (sExistingKey == "" || sExistingKey == sCDKey)
        {
            nTargetSlot = nSlot;
            break;
        }
        nSlot++;
    }

    // PHASE 3: REGISTRATION (Staggered 0.1s)
    DelayCommand(0.1f, [oArea, oPC, sCDKey, nTargetSlot]()
    {
        if (nTargetSlot > 0)
        {
            // Record the CD Key and Object in the Area's VIP List.
            SetLocalString(oArea, "MG_VIP_KEY_" + IntToString(nTargetSlot), sCDKey);
            SetLocalObject(oArea, "MG_VIP_OBJ_" + IntToString(nTargetSlot), oPC);
            
            // Assign the PC their slot number so they know where they "live" in this area.
            SetLocalInt(oPC, "MG_MY_SLOT", nTargetSlot);
            
            // Increment the population count.
            int nPop = GetLocalInt(oArea, "MG_POPULATION");
            SetLocalInt(oArea, "MG_POPULATION", nPop + 1);

            // PHASE 4: DEBUG REPORTING
            if (GetLocalInt(oArea, "MG_DEBUG_ON"))
            {
                SetLocalString(oArea, "MG_DEBUG_MSG", "REGISTRY: Player " + GetName(oPC) + " assigned to VIP Slot " + IntToString(nTargetSlot));
                ExecuteScript("area_debug", oArea);
            }
        }
    });
}
