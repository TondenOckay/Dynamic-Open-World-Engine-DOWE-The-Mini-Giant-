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
    registration and heartbeat activation.
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
    if (!GetIsPC(oPC) || GetIsDM(oPC)) return;

    // PHASE 2: SWITCHBOARD HANDSHAKE (Staggered 0.1s)
    // We do not run registration here. We tell the Switchboard to do it.
    DelayCommand(0.1f, [oArea, oPC]()
    {
        // Pack the data for the Switchboard.
        SetLocalObject(oArea, "MG_SW_TARGET", oPC);
        SetLocalInt(oArea, "MG_SW_EVENT", 100); // 100 = Registration Request
        
        // Execute the central router.
        ExecuteScript("area_switchboard", oArea);
    });

    // PHASE 3: SERVER STATUS CHECK (Staggered 0.5s)
    // If the server is currently "OFF" (Zero-Waste), we ignite the heartbeat.
    DelayCommand(0.5f, [oArea]()
    {
        if (GetLocalInt(oArea, "MG_SERVER_ACTIVE") == FALSE)
        {
            // Mini-server is now turning on.
            SetLocalInt(oArea, "MG_SERVER_ACTIVE", TRUE);
            
            // Execute the Heartbeat through the Switchboard.
            SetLocalInt(oArea, "MG_SW_EVENT", 200); // 200 = Heartbeat Ignition
            ExecuteScript("area_switchboard", oArea);
        }
    });
}
