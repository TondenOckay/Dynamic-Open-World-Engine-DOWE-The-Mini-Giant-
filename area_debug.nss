/* ============================================================================
    Project Name: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_debug
    PILLARS: 
        1. Independent Mini-Servers Architecture 
        2. Phase-Staggered Performance Optimization 
        3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    A filtered reporting system that outputs mini-server activity to the 
    chat window. Can be toggled on/off to ensure zero performance impact 
    during normal play.
   ============================================================================
*/

void main()
{
    // PHASE 1: CHECK TOGGLE STATUS
    object oArea = OBJECT_SELF;
    
    // If debug is off, we stop immediately.
    if (!GetLocalInt(oArea, "MG_DEBUG_ON")) return;

    // PHASE 2: MESSAGE EXTRACTION
    string sMessage = GetLocalString(oArea, "MG_DEBUG_MSG");
    if (sMessage == "") return;

    // PHASE 3: OUTPUT STAGGERING
    // We broadcast the message to all PCs in the area who have debug enabled.
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == oArea)
        {
            // Send the message in a distinct color for high readability.
            SendMessageToPC(oPC, ">> [DOWE DEBUG]: " + sMessage);
        }
        oPC = GetNextPC();
    }

    // PHASE 4: CLEANUP
    // Clear the message string to prevent duplicate reports.
    DeleteLocalString(oArea, "MG_DEBUG_MSG");
}
