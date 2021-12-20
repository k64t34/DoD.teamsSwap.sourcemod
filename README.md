# DoD.teamsSwap.sourcemod is a SouorceMod plugin for game Day of Defeat Source

```EN``` Some maps with timer ( like dod_jagd, dod_foy_rc1, dod_strand, dod_aubercy_b5 ) need gameplay balance.

This plugin swap teams automactic at round end.

This plugin also swap team wins & score.

Best practices use this plugin is insert parameter `dod_teamsSwap` to map config file. 

Example: File `..\dod\cfg\dod_foy_rc1.cfg` contain text
```
dod_teamsSwap 1
```

After map changed parameter `dod_teamsSwap` will set to 0.

If map config file not contain parameter `dod_teamsSwap 1`, there will no swap teams on map.

When swap teams, the sound is played, similar to of the referee's whistle  that of a sports competition.

---
```RU``` Некоторые карты с таймером (например: dod_jagd, dod_foy_rc1, dod_strand, dod_aubercy_b5) требуют игрового баланса.

Этот плагин автоматически меняет местами команды игроков в конце раунда.

Этот плагин также меняет местами командные очки и победы.

Лучшая практика использования этого плагина - вставить параметр `dod_teamsSwap` в файл конфигурации карты.

Пример: Файл `..\dod\cfg\dod_foy_rc1.cfg` содержит текст
```
dod_teamsSwap 1
```
После изменения карты параметр `dod_teamsSwap` будет равен 0.

Если файл конфигурации карты не содержит параметра `dod_teamsSwap 1`, то на карте не будет производится смена команд.

При смене команд проигрывается звук свистка судьи  как на спортивных соревнованиях.
