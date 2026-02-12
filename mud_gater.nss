/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE)
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    Script Name: mud_gather
    DESCRIPTION: Resource extraction with Tool checks and skill-based math.
   ============================================================================
*/

void main() {
    object oPC = OBJECT_SELF;
    string sChat = GetStringLowerCase(GetPCChatMessage());
    string s2DA = GetResRef(GetArea(oPC)) + "_gather";
    int nRow = 0;

    while (nRow < 100) {
        string sKey = GetStringLowerCase(Get2DAString(s2DA, "Trigger", nRow));
        if (sKey == "") break;

        if (FindSubString(sChat, sKey) != -1) {
            // Skill Math
            int nMin = StringToInt(Get2DAString(s2DA, "MinSkill", nRow));
            int nBase = StringToInt(Get2DAString(s2DA, "BaseChance", nRow));
            int nPCLevel = GetLocalInt(oPC, "SKILL_GATHER");

            if (nPCLevel < nMin) {
                SendMessageToPC(oPC, "DOWE: Gathering skill too low. Required: " + IntToString(nMin));
                return;
            }

            // Tool Check
            string sTool = Get2DAString(s2DA, "ToolReq", nRow);
            if (sTool != "****" && !GetIsObjectValid(GetItemPossessedBy(oPC, sTool))) {
                SendMessageToPC(oPC, "DOWE: You lack the required tool (" + sTool + ")");
                return;
            }

            // 10% Skill Gain
            if (d100() <= 10) SetLocalInt(oPC, "SKILL_GATHER", nPCLevel + 1);

            // Roll Success
            int nChance = nBase + ((nPCLevel - nMin) * 5);
            if (d100() <= nChance) {
                SendMessageToPC(oPC, Get2DAString(s2DA, "Response", nRow));
                // Give items...
            }
            return;
        }
        nRow++;
    }
}
