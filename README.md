# DoD.teamsSwap.sourcemod is a SouorceMod plugin for game Day of Defeat Source

Some maps with timer ( like dod_jagd, dod_foy_rc1, dod_strand, dod_aubercy_b5 ) need gameplay balance.

This plugin swap teams automactic at round end for game Day of Defeat Source .

This plugin also swap team wins & score.

Best practices use this plugin is insert parameter `dod_teamsSwap` to map config file. 

Example: File `..\dod\cfg\dod_foy_rc1.cfg` contain text
```
dod_teamsSwap 1
```

After map changed parameter `dod_teamsSwap` will set to 0.

If map config file not contain parameter `dod_teamsSwap 1`, there will no swap teams on map.
