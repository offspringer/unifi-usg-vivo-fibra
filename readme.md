# Configuração de Unifi Security Gateway

## Introdução
Esta configuração foi criada com o intuito de substituir completamente o hardware disponibilizado pela Vivo Fibra e utilizar o máximo de recursos possíveis do roteador Unifi Security Gateway, mantendo os recursos de Internet e TV (no caso, IPTV).

## Considerações
* **Minimalismo**: manter a menor quantidade de equipamentos possíveis, com as menores dimensões possíveis, podendo instalá-los em caixas de distribuição de sistemas de apartamentos, por exemplo;
* **Qualidade**: obter um ganho de qualidade ao substituir o equipamento original por um mais confiável.

## Estrutura da rede
```
               fibra
                 |
          +---------------+
          |      ONT      |
          +---------------+
                 |
          vlan10 (internet)
            vlan20 (iptv)
            vlan30 (voip)
                 |
                 |
                 | wan1
   +-----------------------------+
   |    Unifi Security Gateway   |
   +-----------------------------+
            eth1 |
                 |
                 |
   +-----------------------------+
   |         Unifi Switch        |
   +-----------------------------+
          | Network          | Network                 
          | Internet         | IPTV
   +----------------+     +-----------------------+
   |  Wifi AP / PC  |     |   Decodificador IPTV  |
   +----------------+     +-----------------------+
```

## Hardware utilizado
* [Unifi Cloud Key Gen2](https://unifi-protect.ui.com/cloud-key-gen2) - modelo: UCK-G2, firmware: UCKG2.apq8053.v1.1.13.818cc5f.200430.0948, controller: v5.13.32-13646-1
* [Unifi Security Gateway](https://www.ui.com/unifi-routing/usg/) - modelo: USG, firmware: v4.4.51.5287926
* [UniFi Switch 16 POE-150W](https://www.ui.com/unifi-switching/unifi-switch-16-150w/) - modelo: US-16-150W, firmware: v4.3.20.11298

## Pré-requisitos
1. ONT corretamente configurada e autenticada na Vivo Fibra
2. ONT conectada na porta eth0 (WAN 1) do Unifi Security Gateway
3. Switch conectado na porta eth1 (LAN 1) do Unifi Security Gateway
4. Unifi Controller inicializado e com todos os dispositivos adotados
5. Ter criadas as seguintes networks: 

        LAN (default VLAN 1 em 10.10.5.0/24)
        Internet (VLAN 10 em 10.10.10.0/24)
        IPTV (VLAN 20 em 10.10.20.0/24 com IGMP Snooping ativado)
        VoIP (VLAN 30 em 10.10.30.0/24)
6. Access Points, switches ou computadores conectados no switch com Port Profile All;
7. Decodificador IPTV conectado no switch com Port Profile IPTV;

## Utilização
1. Copie o arquivo `config.gateway.json` para dentro de seu **Unifi Controller** através de `ssh` (no caso da Cloud Key, a pasta padrão para upload deste arquivo é `/srv/unifi/data/sites/default/`, onde default é o nome do site em questão)
2. Através do **Unifi Controller**, localize o  **Unifi Security Gateway** e force o provisionamento

Pronto, já pode testar sua conexão com a Internet e o funcionamento da IPTV.

## Atualização automática de DNS
Como os servidores DNS utilizados pela operadora podem mudar de tempos em tempos, utilize o script de execução automática para atualizá-los. Observação: o script precisa de uma network chamada IPTV para buscar as informações fazer a atualização.
1. Copie o arquivo `update_iptv_dns.sh` para dentro de seu **Unifi Security Gateway** através de `ssh` (a pasta destino para upload deste arquivo é `/config/scripts/post-config.d/`)
2. Torne-o executável atráves do comando `chmod +x /config/scripts/post-config.d/update_iptv_dns.sh`
3. Execute-o com `sh /config/scripts/post-config.d/update_iptv_dns.sh`

## Problemas conhecidos
### ONT
Algumas ONTs podem não ser compatíveis com a sua região (uma rápida pesquisa no Google pode ajudar);

### Rede
A rede pode ficar lenta se o multicast não estiver funcionando da maneira mais otimizada possível. Se estiver utilizando um switch para distribuir a IPTV para muitos pontos, verifique se o mesmo é compatível com *IGMP Snooping* e se o recurso está habilitado. No caso dos switches gerenciados Unifi, é possível otimizar seu funcionamento desabilizando o `igmp.header_checking` e habilitando o `igmp_fastleave` através de um `config.properties` customizado. Além disso, o **Unifi Security Gateway** mostrará incorretamente que está configurado para DHCP na interface do Unifi Controller e também na própria interface (isto acontece por causa das diversas configurações de VLANs para a interface WAN).

### IPTV
Como a IPTV depende de muitos fatores para funcionar, diversos problemas podem acontecer nesta parte: o decodificador pode não finalizar o setup inicial, a tela pode ficar preta com mensagem de "conteúdo indisponível" após algum tempo, etc.

As causas mais comuns seriam:
1. Rotas estáticas: deve-se verificar se algumas rotas estáticas fornecidades pela Vivo Fibra foram alteradas. Infelizmente, não há muito o que fazer nesta parte, a não ser comparar com as que o roteador original recebe através do protocolo de atualização TR-069;
2. Servidores DNS: assim como as rotas estáticas, eles também podem mudar com o tempo e impedir o correto funcionamento da IPTV. Force a execução do `update_iptv_dns.sh` e tente novamente;
3. IGMP Proxy: este componente é essencial para o correto funcionamento da IPTV, e pode apresentar uma certa instabilidade dependendo da versão do firmware do roteador. Portanto, é sempre válido verificar se o mesmo ainda está rodando através do comando `ps aux | grep igmp` e também analisar como está o multicast através dos comandos `show ip multicast interfaces` e `show ip multicast mfc`.

### VoIP
A configuração de VoIP não foi testada pois não possuo este serviço em minha assinatura;

## Referências
* Documentação do Vyatta: https://docs.huihoo.com/vyatta/6.3/
* UniFi - USG Advanced Configuration Using config.gateway.json: https://help.ubnt.com/hc/en-us/articles/
* UniFi - Explaining the config.properties File: https://help.ui.com/hc/en-us/articles/205146040-UniFi-Explaining-the-config-properties-File215458888-UniFi-How-to-further-customize-USG-configuration-with-config-gateway-json
* Substituindo roteador Vivo Fibra por GPON TP-LINK TX-6610 + Mikrotik: https://forum.vivo.com.br/threads/112037-Substituindo-roteador-Vivo-Fibra-por-GPON-TP-LINK-TX-6610-Mikrotik
* Como configurar um serviço SIP para utilização de VoIP: https://forum.vivo.com.br/threads/114368-Configura%C3%A7%C3%A3o-SIP
