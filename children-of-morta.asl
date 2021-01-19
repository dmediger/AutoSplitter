/* 
 * CHILDREN OF MORTA Any%/IL autosplitter by 4kiZeta
 *
 * This asl contains autosplitters for both Any% and individual level ("IL") runs.
 * Set up separate livesplit layouts for both categories and choose settings accordingly.
 * 
 * For Any% runs make sure to set livesplit timers to REALTIME
 * For "IL" runs make sure to set livesplit timers to GAMETIME
 * 
 * IL time synchronizes with the gametime read from corresponding memory used by the
 * underlying unity engine as demanded by the current category ruleset.
 * 
 * Tested for win x64 systems on game version 1.1.70.2
 */

state("ChildrenOfMorta")
{
    bool pProfileLoaded:  "UnityPlayer.dll",    0x15F4040, 0x0, 0xD8, 0x160, 0xD0, 0x78, 0x48;
    bool pIsInFloor:      "UnityPlayer.dll",    0x15F4040, 0x0, 0x138, 0x108, 0x160, 0xA8, 0xA0, 0x90;
    int  floorsWon:       "mono-2.0-bdwgc.dll", 0x492DC8,  0x100, 0xE18, 0x140, 0x80, 0xF8;
    int  cameraState:     "UnityPlayer.dll",    0x1646F10, 0x0, 0x10, 0x30, 0x38, 0x28, 0x28, 0xEC;
    bool bossHpBarActive: "mono-2.0-bdwgc.dll", 0x523840,  0x0, 0x108, 0x2A8, 0x0, 0x160, 0x258, 0x50;

    int  pDungeon:        "UnityPlayer.dll",    0x1632730, 0x40, 0x740, 0x98, 0x1A8, 0x2E8, 0x28, 0x74;
        // enum pDungeon: Invalid (House)  = -2
        //                Tutorial         = -1
        //                Silk Caverns     = 0
        //                Lost Trenches    = 1
        //                Anai-Dya         = 2
        //                City of Thieves  = 6
        //                The Forest       = 10
        //                The Ziggurat     = 7
        //                Ruins of Barahut = 5
        //                Industrial       = 15
        //                Area 30          = 16
        //                Ou (Temple)      = 20

    float runStartTime:   "mono-2.0-bdwgc.dll", 0x492DC8, 0x100, 0xE18, 0x140, 0x80, 0xE4;
    float pTime:          "mono-2.0-bdwgc.dll", 0x4A23F0, 0x210, 0x1D0;

    int runEndCode:       "mono-2.0-bdwgc.dll", 0x492DE0, 0xA0, 0x1D0, 0x0, 0x60, 0x10, 0x110;
        // RunEndReason:  Death/Default = 0
        //                Win           = 1
        //                ReturnByMenu  = 2
        //                ReturnToTitle = 3

    int localGamemode:    "mono-2.0-bdwgc.dll", 0x492DC8, 0x100, 0xC00, 0x418, 0x140, 0xBC;
        // localGamemode: NG     = 1
        //                NGPlus = 2
}

startup
{
    //Any% mode
    settings.Add("split_any", true, "Run Any% (needs REALTIME setting):");
    settings.Add("split_tutorial", true, "Beating Tutorial", "split_any");
    settings.Add("split_silk", true, "Beating Silk Caverns", "split_any");
    settings.Add("split_trenches", true, "Beating Lost Trenches", "split_any");
    settings.Add("split_anai", true, "Beating Anai-Dya's Dominion", "split_any");
    settings.Add("split_city", true, "Beating City of Thieves", "split_any");
    settings.Add("split_forest", true, "Beating Forest Rescue", "split_any");
    settings.Add("split_ziggurat", true, "Beating Ziggurat", "split_any");
    settings.Add("split_ruins", true, "Beating Ruins of Old Barahut", "split_any");
    settings.Add("split_factory", true, "Beating Industrial Quarters", "split_any");
    settings.Add("split_area30", true, "Beating Area 30", "split_any");
    settings.Add("split_ou", true, "Beating Ou (Final Boss)", "split_any");
    
    //IL mode
    settings.Add("split_IL", false, "Run individual levels (needs GAMETIME setting):");
    settings.Add("split_floors", false, "Split on floor transition", "split_IL");
}

init
{
    //(Re-)Initializing..
    vars.splitCounter_Any = 0;
    vars.splitCdtn_IL = false;
    vars.ouBarCounter = 0;
    vars.ouIsDead = false;
    vars.playDuration = TimeSpan.FromSeconds((double)(0));

    //Counters for preserving dungeon order as a split condition in coherence with individual settings:      
    vars.setCntTrenches   =                     1 + Convert.ToInt32(settings["split_silk"]);
    vars.setCntAnai       = vars.setCntTrenches   + Convert.ToInt32(settings["split_anai"]);
    vars.setCntCity       = vars.setCntAnai       + Convert.ToInt32(settings["split_city"]);
    vars.setCntForest     = vars.setCntCity       + Convert.ToInt32(settings["split_forest"]);
    vars.setCntZiggurat   = vars.setCntForest     + Convert.ToInt32(settings["split_ziggurat"]);
    vars.setCntRuins      = vars.setCntZiggurat   + Convert.ToInt32(settings["split_ruins"]);
    vars.setCntIndustrial = vars.setCntRuins      + Convert.ToInt32(settings["split_factory"]);
    vars.setCntArea       = vars.setCntIndustrial + Convert.ToInt32(settings["split_area30"]);
    vars.setCntOu         = vars.setCntArea       + Convert.ToInt32(settings["split_ou"]);
}

update
{
    if (settings["split_IL"]) {
        vars.playDuration = TimeSpan.FromSeconds((double)(new decimal(current.pTime - current.runStartTime)));
 
        if (current.floorsWon > old.floorsWon) {   //IL split cdtn -> floor is won (counts for last floor as well)
            vars.splitCdtn_IL = true;
        }
    }
    else
    if (settings["split_any"] && current.pDungeon == 20){
        if ( !current.bossHpBarActive && old.bossHpBarActive ){
            vars.ouBarCounter++;
            if (vars.ouBarCounter == 2){
                vars.ouIsDead = true;
            }
        }
        return true;
    }
    else if (settings["split_any"] && old.cameraState < current.cameraState ){ //Reset ouBarCounter at house-to-den transition
        vars.ouBarCounter = 0;
        vars.ouIsDead = false;
        return true;
    }
    return true;
}

start
{
    if (settings["split_any"] && !old.pProfileLoaded && current.pProfileLoaded ){
        
        if (current.localGamemode == 1){
            vars.splitCounter_Any = Convert.ToInt32(!settings["split_tutorial"]);
        }
        else if (current.localGamemode == 2){  
            vars.splitCounter_Any = 1;
        }  

        //Ou Counters
        vars.ouBarCounter = 0;
        vars.ouIsDead = false;

        return true;
    }
    else if (settings["split_IL"]){
        vars.splitCdtn_IL = false;
        return (old.runStartTime != current.runStartTime);
        }
}

split
{
    if( settings["split_any"] ){
        if(vars.splitCounter_Any == 0 && settings["split_tutorial"] &&
           old.pDungeon == -1 && current.pDungeon != -1 ) {
                vars.splitCounter_Any++;
                return true;}
        else        
        if(vars.splitCounter_Any == 1 && settings["split_silk"] && 
           old.pDungeon == 0 && current.floorsWon == 3) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntTrenches && settings["split_trenches"] && 
           old.pDungeon == 1 && current.floorsWon == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntAnai && settings["split_anai"] && 
           old.pDungeon == 2 && current.floorsWon == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else        
        if(vars.splitCounter_Any == vars.setCntCity && settings["split_city"] && 
           old.pDungeon == 6 && current.floorsWon == 3 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntForest && settings["split_forest"] && 
           old.pDungeon == 10 && current.pDungeon != 10 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntZiggurat && settings["split_ziggurat"] && 
           old.pDungeon == 7 && current.floorsWon == 5 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntRuins && settings["split_ruins"] && 
           old.pDungeon == 5 && current.floorsWon == 3 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntIndustrial && settings["split_factory"] && 
           old.pDungeon == 15 && current.floorsWon == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntArea && settings["split_area30"] && 
           old.pDungeon == 16 && current.floorsWon == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntOu && settings["split_ou"] && vars.ouIsDead ) {
                return true;}
    }
    else
    if(   settings["split_IL"] && vars.splitCdtn_IL && !old.pIsInFloor && 
        ((current.pIsInFloor && settings["split_floors"]) || ( current.pDungeon == -2 && old.runEndCode == 0 && current.runEndCode == 1 )) ){
            vars.splitCdtn_IL = false;
            return true;
    }
}

reset
{
    if ( settings["split_any"] && old.pProfileLoaded && !current.pProfileLoaded ) {
        vars.splitCounter_Any = 0;
        return true;
    }
    else
    if ( (settings["split_IL"] && (current.pDungeon == -2 && current.runEndCode == 2) || !current.pProfileLoaded) ){
        vars.splitCdtn_IL = false;
        return true;
    }
}

isLoading
{
}

gameTime
{
    return vars.playDuration; // timespan for IL runs
}

exit
{
    vars.splitCdtn_IL = false;
    vars.reset_IL = false;
    vars.ouBarCounter = 0;
    vars.ouIsDead = false;
}