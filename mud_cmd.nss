/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE)
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: mud_cmd
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    The master parser for all // MUD commands. This script identifies 
    the intent of the player and routes the execution to the appropriate 
    sub-engine (NPC, Craft, or Gather).
   ============================================================================
*/

void main() {
    // PHASE 1: Zero-Waste Initialization
    object oPC = GetPCChatSpeaker();
    string sMsg = GetPCChatMessage(); // Case-sensitive for keywords later
    string sCmd = GetStringLowerCase(sMsg);

    // Only process if using the // trigger
    if (GetSubString(sCmd, 0, 2) != "//") return;

    // PHASE 2: Phase-Staggered Routing
    // We check for specific MUD keywords to determine which script to fire.
    
    // Check for Crafting Keywords
    if (FindSubString(sCmd, "craft") != -1 || FindSubString(sCmd, "combine") != -1 || FindSubString(sCmd, "forge") != -1) {
        ExecuteScript("mud_craft", oPC);
    }
    // Check for Gathering Keywords
    else if (FindSubString(sCmd, "gather") != -1 || FindSubString(sCmd, "mine") != -1 || FindSubString(sCmd, "pick") != -1 || FindSubString(sCmd, "chop") != -1) {
        ExecuteScript("mud_gather", oPC);
    }
    // Default to NPC/Object/Quest Engine
    else {
        ExecuteScript("mud_npc", oPC);
    }

    // PHASE 3: Immersion Cleanup
    // Silence the chat message so other players don't see the technical command.
    SetPCChatMessage("");
}
