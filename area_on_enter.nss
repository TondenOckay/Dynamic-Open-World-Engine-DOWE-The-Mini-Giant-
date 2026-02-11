/* ============================================================================
    Project Name: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_on_enter
    PILLARS: 
        1. Independent Mini-Servers Architecture 
        2. Phase-Staggered Performance Optimization 
        3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    The primary ignition script for the area mini-server. It identifies the 
    entering player and initiates the Switchboard handshake to begin 
    registration, heartbeat activation, and the Live_NPC testing system.
   ============================================================================
*/

// --- 2DA REFERENCE NOTES ---
// // No 2DA files are required for the initiation of the on_enter event.

void main()
{
    // PHASE 1: VALIDATION
    // Check if the object entering is a PC and not a DM.
    object oPC = GetEnteringObject();
    object oArea = OBJECT_SELF;

    // If it's not a player, we exit immediately to save CPU cycles.
    if (GetIsPC(oPC) == FALSE || GetIsDM(oPC) == TRUE) return;

    // PHASE 2: SWITCHBOARD HANDSHAKE (Staggered 0.1s)
    // We set variables on the area, then call the switchboard for registration.
    float fStagger = 0.1;
    DelayCommand(fStagger, SetLocalObject(oArea, "MG_SW_TARGET", oPC));
    DelayCommand(fStagger, SetLocalInt(oArea, "MG_SW_EVENT", 100)); // 100 = Registration Request
    
    // Execute the central router with a tiny 0.01s offset to ensure variables are set.
    DelayCommand(fStagger + 0.01, ExecuteScript("area_switchboard", oArea));

    // PHASE 3: SERVER STATUS CHECK (Staggered 0.5s)
    // If the server is currently "OFF" (Zero-Waste), we ignite the heartbeat.
    DelayCommand(0.5, ExecuteScript("area_heartbeat", oArea));

    // PHASE 4: LIVE_NPC TESTER IGNITION (Staggered 0.7s)
    // Notes: This fires the testing system through the switchboard. 
    // It will only execute if MG_LIVE_NPC_ON is set to TRUE on the area.
    float fTestStagger = 0.7;
    DelayCommand(fTestStagger, SetLocalInt(oArea, "MG_SW_EVENT", 400)); // 400 = Live_NPC System
    DelayCommand(fTestStagger + 0.01, ExecuteScript("area_switchboard", oArea));
}
