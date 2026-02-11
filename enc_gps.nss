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

void main()
{
    object oArea = OBJECT_SELF;
    int nPop = GetLocalInt(oArea, "MG_POPULATION");
    if (nPop <= 0) return;

    // PHASE 1: CREATURE LIST MAINTENANCE (Your cleanup loop)
    int nTotalEnc = GetLocalInt(oArea, "MG_ENC_COUNT");
    int j;
    for (j = 1; j <= nTotalEnc; j++)
    {
        float fCleanStag = j * 0.05;
        DelayCommand(fCleanStag, SetLocalInt(oArea, "MG_CLEANUP_IDX", j));
        DelayCommand(fCleanStag + 0.01, ExecuteScript("enc_list_clean", oArea));
    }

    // PHASE 2: PLAYER SPATIAL SCAN (The Heartbeat Pulse)
    int i;
    for (i = 1; i <= 100; i++)
    {
        object oPC = GetLocalObject(oArea, "MG_VIP_OBJ_" + IntToString(i));

        // VOID JUMPING: Skip null objects OR players with no CD Key (crashed).
        if (!GetIsObjectValid(oPC) || GetPCPublicCDKey(oPC) == "") continue;

        float fPlayerStagger = i * 0.5;

        // CHECK A: Combat Check
        if (GetIsInCombat(oPC)) continue;

        // CHECK B: 40% Encounter Roll
        if (Random(100) < 40)
        {
            DelayCommand(fPlayerStagger, SetLocalObject(oArea, "MG_SW_TARGET", oPC));
            DelayCommand(fPlayerStagger, SetLocalInt(oArea, "MG_SW_EVENT", 500)); 
            DelayCommand(fPlayerStagger + 0.05, ExecuteScript("area_switchboard", oArea));
        }
    }
}
