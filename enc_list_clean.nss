/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: enc_list_clean
    DESCRIPTION: Phase 1 of GPS logic. Cleans the ID list and handles 
    ownership transfer if the original "Hunter" PC is gone.
   ============================================================================
*/

void main()
{
    object oArea = OBJECT_SELF;
    int nIdx = GetLocalInt(oArea, "MG_CLEANUP_IDX");
    string sID = IntToString(nIdx);
    object oNPC = GetLocalObject(oArea, "MG_ENC_ID_" + sID);

    // 1. Check if the creature is gone or dead.
    if (!GetIsObjectValid(oNPC) || GetIsDead(oNPC))
    {
        DeleteLocalObject(oArea, "MG_ENC_ID_" + sID);
        return;
    }

    // 2. Ownership & Distance Logic
    object oHunter = GetLocalObject(oNPC, "MG_ENC_OWNER");
    float fDist = GetDistanceBetween(oNPC, oHunter);

    // If owner is dead or 50m+ away, look for a new PC within 30m.
    if (!GetIsObjectValid(oHunter) || GetIsDead(oHunter) || fDist > 50.0)
    {
        object oNewOwner = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oNPC);
        
        if (GetIsObjectValid(oNewOwner) && GetDistanceBetween(oNPC, oNewOwner) <= 30.0)
        {
            SetLocalObject(oNPC, "MG_ENC_OWNER", oNewOwner);
            // Update the NPC's tag/identity to the new player's ID if needed.
        }
        else
        {
            // No players nearby? Despawn to save resources (Zero-Waste).
            DestroyObject(oNPC);
        }
    }
}
