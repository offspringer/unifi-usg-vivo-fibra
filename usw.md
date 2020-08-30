# Configuração de Unifi Managed Switch (USW)

## Introdução
Esta configuração foi criada com o intuito de otimizar o funcionamento do protocolo IGMP para IPTV da Vivo Fibra em um Unifi Managed Switch.

## Hardware utilizado
* [UniFi Switch 16 POE-150W](https://www.ui.com/unifi-switching/unifi-switch-16-150w/) - modelo: US-16-150W, firmware: v4.3.20.11298

## Pré-requisitos
1. Ter seguido os passos descritos [aqui](readme.md).

## Utilização
1. Acesse o switch através de `ssh` e execute o comando `grep id= /tmp/system.cfg`. Identifique o índice equivalente à VLAN da IPTV. No caso desta configuração, o índice equivalente para a VLAN 20 é igual a 3;
2. Altere o arquivo `config.properties` para que o índice na configuração `switch.vlan.3.igmp_fastleave` reflita o número encontrado no passo anterior. Atenção, o número 3 desta configuração não é o número da VLAN;
3. Copie o arquivo `config.properties` para dentro de seu **Unifi Controller** através de `ssh` (no caso da Cloud Key, a pasta padrão para upload deste arquivo é `/srv/unifi/data/sites/default/`, onde default é o nome do site em questão)
4. Através do **Unifi Controller**, localize o  **Unifi Managed Switch** e force o provisionamento.

## Validação

1. Acesse novamente o switch através de `ssh` para efetuar uma validação de configuração IGMP;
2. Entre no modo de gerenciamento com o comando `telnet localhost`;
3. Habilite o modo de gerencimando com a instrução `enable`;
4. Entre no modo VLAN com a instrução `vlan database`;
5. Visualize a configuração geral de IGMP com a instrução `show igmpsnooping`. Verifique se a opção IGMP header validation aparece desabilitada, como no exemplo a seguir:
    ```
    Admin Mode..................................... Enable
    Multicast Control Frame Count.................. 8249
    IGMP header validation......................... Disabled
    Interfaces Enabled for IGMP Snooping........... None
    VLANs enabled for IGMP snooping................ 1
    ```
6. Visualize a configuração geral de IGMP específica para a VLAN 20 com a instrução `show igmpsnooping 20`. Verifique se a opção Fast Leave Mode aparece habilitada, como no exemplo a seguir:
    ```
    VLAN ID........................................ 1
    IGMP Snooping Admin Mode....................... Enabled
    Fast Leave Mode................................ Enabled
    Group Membership Interval (secs)............... 260
    Max Response Time (secs)....................... 10
    Multicast Router Expiry Time (secs)............ 0
    Report Suppression Mode........................ Disabled
    ```
7. Pronto, já pode testar o funcionamento da IPTV.