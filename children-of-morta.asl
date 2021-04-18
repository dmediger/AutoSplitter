/* 
 * CHILDREN OF MORTA Any%/Family Trials autosplitter by 4kiZeta
 *
 * This asl contains autosplitters for both Any% and Family Trials runs.
 * Set up separate livesplit layouts for both categories and choose settings accordingly.
 * 
 * For Any% runs make sure to set livesplit timers to REALTIME
 * For Family Trials runs make sure to set livesplit timers to GAMETIME
 * 
 * In case of Family Trials, time synchronizes with the gametime read from corresponding memory used by the
 * underlying unity engine as demanded by the current category ruleset.
 * 
 * Tested for win x64 systems on game version 1.2.55
 */

state("ChildrenOfMorta")
{
    bool pProfileLoaded:  "UnityPlayer.dll",    0x15F4040,  0x0,  0xD8, 0x160,  0xD0,  0x78,  0x48;
    int  passedFloors:    "UnityPlayer.dll",    0x15F8C00, 0xC88, 0xF8,  0x50,  0x78,  0x20,  0x48, 0x130;
    bool bossHpBarActive: "mono-2.0-bdwgc.dll",  0x523850,  0x0, 0x108, 0x418,   0x0, 0x168, 0x258,  0x50;

    int  pDungeon:        "UnityPlayer.dll",    0x15F4040, 0x0, 0xD8, 0x160, 0x98, 0x48, 0xD0, 0x74;
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
        //                Endless          = 30

    int runEndCode:       "mono-2.0-bdwgc.dll", 0x492DE0, 0xA0, 0x1D0, 0x0, 0x60, 0x10, 0x110;
        // RunEndReason:  Death/Default = 0
        //                Win           = 1
        //                ReturnByMenu  = 2
        //                ReturnToTitle = 3

    int globalGameMode:   "UnityPlayer.dll", 0x16A8100, 0x50, 0xD0, 0x30, 0x8, 0x118, 0x16C;
        // Gamemode:      Invalid = 0
        //                Story   = 1
        //                Trials  = 2

    int localGamemode:    "mono-2.0-bdwgc.dll", 0x492DC8, 0x100, 0xC00, 0x418, 0x140, 0xBC;
        // localGamemode: NG     = 1
        //                NGPlus = 2

    //regarding Family Trials mode
    float runStartTime:   "UnityPlayer.dll",    0x15F8C00, 0xC88,  0xF8,  0x50,  0x78, 0x20,  0x48, 0x114;
    float pTime:          "mono-2.0-bdwgc.dll",  0x523800,  0xD0, 0x170, 0x190,  0x44;
    bool  pIsInTrialsRun: "UnityPlayer.dll",    0x15F8C00, 0xC88,  0xF8,  0x50,  0x78, 0x20, 0x159;
    int   pTrialsEndCode: "UnityPlayer.dll",    0x1634700,   0x8,  0x28, 0x288,  0xD0, 0x90,  0x2C;
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
    
    //Family Trials mode
    settings.Add("split_trials",  false, "Run Family Trials (needs GAMETIME setting):");
    settings.Add("split_floor1",  false, "After Floor 1", "split_trials");
    settings.Add("split_floor2",  false, "After Floor 2", "split_trials");
    settings.Add("split_floor3",  false, "After Floor 3", "split_trials");
    settings.Add("split_floor4",  false, "After Floor 4 (Shop)", "split_trials");
    settings.Add("split_floor5",  false, "After Floor 5", "split_trials");
    settings.Add("split_floor6",  false, "After Floor 6", "split_trials");
    settings.Add("split_floor7",  false, "After Floor 7 (Shop)", "split_trials");
    settings.Add("split_floor8",  false, "After Floor 8 (Boss 1)", "split_trials");
    settings.Add("split_floor9",  false, "After Floor 9", "split_trials");
    settings.Add("split_floor10", false, "After Floor 10", "split_trials");
    settings.Add("split_floor11", false, "After Floor 11", "split_trials");
    settings.Add("split_floor12", false, "After Floor 12 (Shop)", "split_trials");
    settings.Add("split_floor13", false, "After Floor 13 (Boss 2)", "split_trials");
    settings.Add("split_floor14", false, "After Floor 14", "split_trials");
    settings.Add("split_floor15", false, "After Floor 15", "split_trials");
    settings.Add("split_floor16", false, "After Floor 16 (Shop)", "split_trials");
    settings.Add("split_floor17", false, "After Floor 17 (Aziz)", "split_trials");
    settings.Add("split_floor18", false, "After Floor 18 (Ou)", "split_trials");
}

init
{
    //(Re-)Initializing..
    vars.splitCounter_Any = 0;
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
    //Dirty Debug
    if(current.pIsInTrialsRun) print("Is in run!");
    else if (!current.pIsInTrialsRun) print("Apparently not in run!!");
    else print("Invalid bool pIsInTrialsRun");
    print("passed floors: "+current.passedFloors);
    print("Run start time: "+current.runStartTime);
    print("Time: "+current.pTime);

    if (settings["split_trials"]) {
        vars.playDuration = TimeSpan.FromSeconds((double)(new decimal(current.pTime - current.runStartTime)));
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
    else if (settings["split_any"] && old.pDungeon == 20 && current.pDungeon != 20 ){ //Reset ouBarCounter
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
    else if (settings["split_trials"]){
        return (current.pIsInTrialsRun);
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
           old.pDungeon == 0 && current.passedFloors == 3) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntTrenches && settings["split_trenches"] && 
           old.pDungeon == 1 && current.passedFloors == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntAnai && settings["split_anai"] && 
           old.pDungeon == 2 && current.passedFloors == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else        
        if(vars.splitCounter_Any == vars.setCntCity && settings["split_city"] && 
           old.pDungeon == 6 && current.passedFloors == 3 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntForest && settings["split_forest"] && 
           old.passedFloors == 0 && current.passedFloors == 1 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntZiggurat && settings["split_ziggurat"] && 
           old.pDungeon == 7 && current.passedFloors == 5 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntRuins && settings["split_ruins"] && 
           old.pDungeon == 5 && current.passedFloors == 3 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntIndustrial && settings["split_factory"] && 
           old.pDungeon == 15 && current.passedFloors == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntArea && settings["split_area30"] && 
           old.pDungeon == 16 && current.passedFloors == 4 ) {
                vars.splitCounter_Any++;
                return true;}
        else
        if(vars.splitCounter_Any == vars.setCntOu && settings["split_ou"] && vars.ouIsDead ) {
                return true;}
    }
    else //regarding Family Trials mode
    if( settings["split_trials"] && old.passedFloors == current.passedFloors - 1 ){
        if ( settings["split_floor1"] && old.passedFloors == 0) return true;
        else 
        if ( settings["split_floor2"] && old.passedFloors == 1) return true;
        else
        if ( settings["split_floor3"] && old.passedFloors == 2) return true;
        else 
        if ( settings["split_floor4"] && old.passedFloors == 3) return true;
        else
        if ( settings["split_floor5"] && old.passedFloors == 4) return true;
        else 
        if ( settings["split_floor6"] && old.passedFloors == 5) return true;
        else
        if ( settings["split_floor7"] && old.passedFloors == 6) return true;
        else 
        if ( settings["split_floor8"] && old.passedFloors == 7) return true;
        else
        if ( settings["split_floor9"] && old.passedFloors == 8) return true;
        else 
        if ( settings["split_floor10"] && old.passedFloors == 9) return true;
        else
        if ( settings["split_floor11"] && old.passedFloors == 10) return true;
        else 
        if ( settings["split_floor12"] && old.passedFloors == 11) return true;
        else
        if ( settings["split_floor13"] && old.passedFloors == 12) return true;
        else 
        if ( settings["split_floor14"] && old.passedFloors == 13) return true;
        else
        if ( settings["split_floor15"] && old.passedFloors == 14) return true;
        else 
        if ( settings["split_floor16"] && old.passedFloors == 15) return true;
        else
        if ( settings["split_floor17"] && old.passedFloors == 16) return true;
        else 
        if ( settings["split_floor18"] && old.passedFloors == 17) return true;
    }
}

reset
{
    if ( settings["split_any"] && old.pProfileLoaded && !current.pProfileLoaded ) {
        vars.splitCounter_Any = 0;
        return true;
    }
    else
    if ( settings["split_trials"] && !current.pIsInTrialsRun && current.pTrialsEndCode != 1) {
        return true;
    }
}

gameTime
{
    return vars.playDuration;
}

exit
{
    vars.ouBarCounter = 0;
    vars.ouIsDead = false;
}
