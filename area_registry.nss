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
    Maintains O(1) efficiency by avoiding list reshuffling.
   ============================================================================
*/

// --- 2DA REFERENCE NOTES ---
// // This script uses local variable indexing; no 2DA files required.

void main()
{
    // PHASE 1: DATA RETRIEVAL
    object oArea = OBJECT_SELF;
    // Retrieve the target PC from the Switchboard packet.
    object oPC = GetLocalObject(oArea, "MG_SW_TARGET");
    
    // Triple-Check: Ensure the PC object is valid before continuing.
    if (!GetIsObjectValid(oPC)) return;

    string sCDKey = GetPCPublicCDKey(oPC);
    int nMaxSlots = 100; // The maximum capacity for this individual mini-server.
    int nSlot = 1;
    int nTargetSlot = 0;

    // PHASE 2: VOID DETECTION (Scanning for an empty spot)
    // Notes: We loop to find the first "" (void) in the list.
    // This allows us to fill gaps left by players who departed.
    while (nSlot <= nMaxSlots)
    {
        string sExistingKey = GetLocalString(oArea, "MG_VIP_KEY_" + IntToString(nSlot));
        
        // If the slot is empty, or the player is already registered here.
        if (sExistingKey == "" || sExistingKey == sCDKey)
        {
            nTargetSlot = nSlot;
            break;
        }
        nSlot++;
    }

    // PHASE 3: REGISTRATION & STAGGERED DATA ENTRY
    // Notes: We use standard DelayCommand calls to stagger variable assignment.
    if (nTargetSlot > 0)
    {
        float fStagger = 0.1;

        // Record the identity in the Area's VIP List.
        DelayCommand(fStagger, SetLocalString(oArea, "MG_VIP_KEY_" + IntToString(nTargetSlot), sCDKey));
        DelayCommand(fStagger, SetLocalObject(oArea, "MG_VIP_OBJ_" + IntToString(nTargetSlot), oPC));
        
        // Assign the PC their slot ID for quick reference later.
        DelayCommand(fStagger + 0.05, SetLocalInt(oPC, "MG_MY_SLOT", nTargetSlot));
        
        // Update the mini-server population count.
        int nPop = GetLocalInt(oArea, "MG_POPULATION");
        DelayCommand(fStagger + 0.1, SetLocalInt(oArea, "MG_POPULATION", nPop + 1));

        // PHASE 4: DEBUG REPORTING
        if (GetLocalInt(oArea, "MG_DEBUG_ON"))
        {
            float fDebugDelay = fStagger + 0.2;
            DelayCommand(fDebugDelay, SetLocalString(oArea, "MG_DEBUG_MSG", "REGISTRY: Player " + GetName(oPC) + " assigned to VIP Slot " + IntToString(nTargetSlot)));
            DelayCommand(fDebugDelay + 0.01, ExecuteScript("area_debug", oArea));
        }
    }
}
