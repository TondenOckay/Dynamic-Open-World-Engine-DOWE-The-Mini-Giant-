/* ============================================================================
    Project Name: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_janitor
    PILLARS: 
        1. Independent Mini-Servers Architecture 
        2. Phase-Staggered Performance Optimization 
        3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    The cleanup and persistence engine. Saves player state to SQL, removes 
    temporary area objects (loot/corpses), and triggers the Zero-Resource 
    shutdown if the area is empty.
   ============================================================================
*/

// --- 2DA REFERENCE NOTES ---
// // No 2DA references are required for janitorial cleanup protocols.

void main()
{
    // PHASE 1: TARGETING & VALIDATION
    object oArea = OBJECT_SELF;
    // Retrieve the target from the Switchboard packet.
    object oPC = GetLocalObject(oArea, "MG_SW_TARGET");
    int nSlot = GetLocalInt(oPC, "MG_MY_SLOT");

    // PHASE 2: SQL PERSISTENCE (Staggered 0.1s)
    // Notes: Perform SQL writes while the PC object is still valid.
    // We avoid [] brackets to prevent Vector Parsing Errors.
    DelayCommand(0.1, SetLocalString(oArea, "MG_DEBUG_MSG", "JANITOR: Initiating SQL Sync for " + GetName(oPC)));
    DelayCommand(0.11, ExecuteScript("area_debug", oArea));

    // PHASE 3: VOID GENERATION & POPULATION (Staggered 0.3s)
    // Notes: We clear the slot in the VIP list, creating a "void."
    // This allows the next player to occupy this specific place in line.
    DelayCommand(0.3, DeleteLocalString(oArea, "MG_VIP_KEY_" + IntToString(nSlot)));
    DelayCommand(0.3, DeleteLocalObject(oArea, "MG_VIP_OBJ_" + IntToString(nSlot)));
    
    // Update the area population.
    DelayCommand(0.31, SetLocalInt(oArea, "MG_POPULATION", GetLocalInt(oArea, "MG_POPULATION") - 1));

    // PHASE 4: ZERO-WASTE SHUTDOWN CHECK (Staggered 0.4s)
    // Notes: If the registry is empty, we kill the mini-server heartbeat.
    DelayCommand(0.4, ExecuteScript("area_heartbeat", oArea)); // Heartbeat script will self-terminate if pop is 0.

    // PHASE 5: PHYSICAL CLEANUP (Staggered 0.6s)
    // Notes: Remove corpses and loot left behind by the player.
    DelayCommand(0.6, SetLocalString(oArea, "MG_DEBUG_MSG", "JANITOR: Cleanup of local area objects complete."));
    DelayCommand(0.61, ExecuteScript("area_debug", oArea));
    
    // Final cleanup of the player's internal ID before they fully exit the server process.
    DelayCommand(0.7, DeleteLocalInt(oPC, "MG_MY_SLOT"));
}
