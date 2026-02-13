export const translations = {
    pt: {
        portal: {
            text: {
                metaTitle: 'Resgate SOS',
                metaDescription:
                    'Plataforma offline-first de comunicacao e coordenacao em emergencias.',
                languageSelector: 'Idioma',
                languageAuto: 'Auto (localizacao)',
                languageFallback: 'Conteudo exibido em ingles para este idioma.',
                heroEyebrow: 'Resgate SOS • portal de crise',
                heroTitle: 'Comunidade conectada mesmo sem Internet.',
                heroLead:
                    'Rede mesh offline para salvar vidas em desastres naturais, caos urbano e isolamento total. Cada no servidor vira hotspot, distribui todas as versoes do sistema e hospeda um portal local.',
                heroActions: {
                    downloads: 'Baixar versoes',
                    assistant: 'Ver assistente offline',
                },
                heroBadges: ['Offline-first', 'Mesh multimeios', 'IA minima local', 'Portal local'],
                panelTitle: 'Estado do no',
                panelLabels: {
                    edition: 'Edicao',
                    mode: 'Modo',
                    http: 'HTTP',
                    mesh: 'Mesh',
                },
                panelMode: 'Servidor local',
                panelFooter: 'Compartilhe este portal via Wi-Fi local ou cabo.',
                howItWorksTitle: 'Como funciona em cenarios de caos',
                howItWorksLead:
                    'O sistema cria uma malha local entre celulares, desktops, TVs e wearables. Mesmo sem Internet, a comunidade compartilha mensagens, mapas e alertas.',
                assistantTitle: 'Assistente offline (IA minima)',
                assistantLead:
                    'Sem depender de nuvem. O assistente local entrega checklists, primeiros socorros e orientacao de construcao rapida. Ele roda no servidor e tambem esta embutido neste portal.',
                assistantSimTitle: 'Simulador rapido',
                assistantScenarioLabel: 'Cenario',
                assistantResourcesLabel: 'Recursos disponiveis',
                assistantInjuriesLabel: 'Ferimentos observados',
                assistantApiLabel: 'API do assistente local',
                assistantPrioritiesLabel: 'Prioridades',
                assistantSafetyLabel: 'Seguranca',
                assistantCoordinationLabel: 'Coordenacao',
                assistantCommsLabel: 'Comunicacao',
                assistantResourceActionsLabel: 'Acoes por recurso',
                assistantFirstAidLabel: 'Primeiros socorros',
                assistantDisclaimer:
                    'Assistente offline baseado em regras. Nao substitui profissionais.',
                serverTitle: 'No servidor como host web',
                serverLead:
                    'Cada no servidor carrega todas as versoes do sistema e publica este portal local. Assim a comunidade baixa apps, consulta guias e registra eventos sem Internet.',
                serverRunTitle: 'Executar o servidor',
                serverRunNote:
                    'Use SOS_WEB_ROOT, SOS_HTTP_PORT e SOS_MESH_PORT para configurar via ambiente.',
                serverOffersTitle: 'O que o no oferece',
                serverOffers: [
                    'Portal local com downloads e guias',
                    'API de assistente offline',
                    'Registro rapido de vitimas e recursos',
                    'Distribuicao de atualizacoes dentro da rede',
                ],
                telemetry: {
                    title: 'Telemetria offline',
                    lead:
                        'Monitore uso, saude da malha e eventos críticos mesmo sem Internet. Os dados ficam locais e podem ser exportados.',
                    statusTitle: 'Status da telemetria',
                    statusLabel: 'Status',
                    statusLoading: 'Carregando',
                    statusReady: 'Ativa',
                    statusUnavailable: 'Indisponivel',
                    eventsLabel: 'Eventos armazenados',
                    nodesLabel: 'Nos distintos',
                    rangeLabel: 'Intervalo',
                    typesTitle: 'Tipos mais frequentes',
                    emptyTypes: 'Sem dados no momento',
                    note:
                        'Disponivel quando o portal e servido pelo Java Server local. Use /telemetry/export para CSV.',
                    errorNote: 'Nao foi possivel carregar a telemetria local.',
                },
                techTitle: 'Compatibilidade total de comunicacao',
                techLead:
                    'O Resgate SOS foi desenhado para ser um grande hotspot. Cada ponto e um no cross de tecnologias: Wi-Fi, BLE, Ethernet e futuros modulos de radio, satelite e optical.',
                techCards: [
                    {
                        title: 'Hoje operacional',
                        items: [
                            'Mesh overlay com encaminhamento',
                            'Wi-Fi mDNS + TCP',
                            'Bluetooth LE',
                            'Portal web offline',
                        ],
                    },
                    {
                        title: 'Em expansao',
                        items: [
                            'Bluetooth Classic e Mesh',
                            'LoRa / LoRaWAN',
                            'Optico e acustico',
                            'Radio VHF/UHF',
                        ],
                    },
                    {
                        title: 'Visao total',
                        items: [
                            'Sat D2D e redes nao-terrestres',
                            'IoT de emergencia (sensores)',
                            'Microgrids e PLC',
                            'Broadcast local (ATSC/DVB/ISDB)',
                        ],
                    },
                ],
                downloadsTitle: 'Downloads offline',
                downloadsLead:
                    'Todas as edicoes ficam disponiveis no no servidor. Baixe e instale rapidamente em cada dispositivo.',
                downloadsNote:
                    'Windows: use o ZIP e execute o .exe dentro da pasta extraida.',
                checklistsTitle: 'Checklists de resiliencia',
                checklistsLead:
                    'Use como guia rapido para organizar a comunidade em poucas horas.',
                commsTitle: 'Codigos foneticos e comunicacao',
                commsLead:
                    'Padronize chamadas para evitar ruido. Use linguagem simples, confirmacao e codigos reconhecidos internacionalmente.',
                commsProtocolsTitle: 'Protocolos essenciais',
                phoneticTitle: 'Alfabeto fonetico',
                phoneticNote: 'Use para soletrar nomes, ruas, IDs e coordenadas.',
                prepTitle: 'Preparacao antes da crise',
                prepLead:
                    'Planejamento e kit basico reduzem risco em cenarios como inundacoes, apagao prolongado e isolamento.',
                femaTitle: 'Informacoes FEMA (Preparedness Grants)',
                femaLead:
                    'Resumo offline baseado na pagina oficial de preparedness grants, com foco em programas, recursos e avisos de financiamentos.',
                femaNote1:
                    'Fonte: FEMA.gov (Preparedness Grants). Verifique atualizacoes quando online.',
                femaNote2:
                    'Reuso: a FEMA informa que a maior parte do conteudo e de dominio publico, mas alguns materiais podem ter direitos autorais e credito especifico.',
                survivalTitle: 'Topicos de sobrevivencia em crises',
                survivalLead:
                    'Priorize agua, abrigo, higiene e seguranca comunitaria. Ajuste as acoes ao clima e ao risco local.',
                safetyTitle: 'Seguranca e limites',
                safetyLead:
                    'O Resgate SOS acelera coordenacao comunitaria, mas nao substitui socorristas profissionais. Sempre priorize a seguranca das pessoas.',
                safetyItems: [
                    'Assistente offline e baseado em regras',
                    'Evite procedimentos invasivos sem treinamento',
                    'Registre eventos para melhorar a resposta',
                    'Compartilhe apenas informacoes essenciais',
                ],
            },
            downloads: {
                targets: {
                    android: 'Android Mobile',
                    tv: 'TV Box',
                    wear: 'Wear OS',
                },
                windowsZip: 'Windows (ZIP)',
                javaZip: 'Java Node (ZIP)',
                javaJar: 'Java Node (JAR)',
            },
            quickStart: [
                {
                    title: '1. Ative o no servidor',
                    text: 'Ligue o Java Server e compartilhe o portal local para todos.',
                },
                {
                    title: '2. Anuncie o ponto de apoio',
                    text: 'Defina local seguro, agua, energia e triagem.',
                },
                {
                    title: '3. Registre pessoas e recursos',
                    text: 'Use o portal para listar feridos, desaparecidos e suprimentos.',
                },
                {
                    title: '4. Distribua tarefas',
                    text: 'Organize equipes por comunicacao, energia, agua e resgate.',
                },
            ],
            commsBasics: [
                'Defina canal oficial e horarios de chamada',
                'Use formato padrao: quem chama, local, situacao, necessidades',
                'Repita coordenadas e confirme recebimento',
                'Mensagens curtas, objetivas e sem ruido',
                'Evite dados pessoais; use IDs e pontos de referencia',
                'Use horario 24h e confirme proxima atualizacao',
            ],
            phoneticAlphabet: [
                { letter: 'A', code: 'Alfa' },
                { letter: 'B', code: 'Bravo' },
                { letter: 'C', code: 'Charlie' },
                { letter: 'D', code: 'Delta' },
                { letter: 'E', code: 'Echo' },
                { letter: 'F', code: 'Foxtrot' },
                { letter: 'G', code: 'Golf' },
                { letter: 'H', code: 'Hotel' },
                { letter: 'I', code: 'India' },
                { letter: 'J', code: 'Juliett' },
                { letter: 'K', code: 'Kilo' },
                { letter: 'L', code: 'Lima' },
                { letter: 'M', code: 'Mike' },
                { letter: 'N', code: 'November' },
                { letter: 'O', code: 'Oscar' },
                { letter: 'P', code: 'Papa' },
                { letter: 'Q', code: 'Quebec' },
                { letter: 'R', code: 'Romeo' },
                { letter: 'S', code: 'Sierra' },
                { letter: 'T', code: 'Tango' },
                { letter: 'U', code: 'Uniform' },
                { letter: 'V', code: 'Victor' },
                { letter: 'W', code: 'Whiskey' },
                { letter: 'X', code: 'X-ray' },
                { letter: 'Y', code: 'Yankee' },
                { letter: 'Z', code: 'Zulu' },
            ],
            commsCodes: [
                {
                    title: 'Prioridade internacional',
                    items: [
                        'MAYDAY = perigo grave e imediato',
                        'PAN-PAN = urgencia sem risco imediato',
                        'SECURITE = aviso de seguranca',
                    ],
                },
                {
                    title: 'Formato de pedido de ajuda',
                    items: [
                        'Quem chama + localizacao clara',
                        'O que aconteceu e riscos ativos',
                        'Quantidade de pessoas e condicoes',
                        'Recursos disponiveis e necessidade principal',
                    ],
                },
                {
                    title: 'SITREP (relatorio rapido)',
                    items: [
                        '1) Situacao atual',
                        '2) Localizacao e rotas',
                        '3) Pessoas afetadas',
                        '4) Recursos e falhas',
                        '5) Necessidades urgentes',
                        '6) Proxima atualizacao',
                    ],
                },
                {
                    title: 'Nota sobre codigos',
                    items: [
                        'Codigos 10 e Q variam por regiao',
                        'Sempre confirme o padrao com a equipe',
                    ],
                },
            ],
            preparednessChecklist: [
                {
                    title: 'Kit essencial',
                    items: [
                        'Agua potavel para pelo menos 72h',
                        'Alimentos nao pereciveis e abridor manual',
                        'Lanternas, baterias e carregadores',
                        'Kit de primeiros socorros e medicamentos',
                        'Copias de documentos e contatos',
                    ],
                },
                {
                    title: 'Plano familiar',
                    items: [
                        'Ponto de encontro definido',
                        'Contatos fora da area',
                        'Rotas alternativas de evacuacao',
                        'Lista de pessoas vulneraveis',
                    ],
                },
                {
                    title: 'Energia e comunicacao',
                    items: [
                        'Painel solar ou gerador com ventilacao',
                        'Radio VHF/UHF e pilhas sobressalentes',
                        'Mapas offline e pontos de apoio',
                        'Identificadores de equipe',
                    ],
                },
                {
                    title: 'Documentos e financas',
                    items: [
                        'Copias fisicas e digitais de documentos',
                        'Lista de contatos e enderecos essenciais',
                        'Dinheiro em especie para emergencias',
                        'Receitas e historico medico basico',
                    ],
                },
                {
                    title: 'Saude e necessidades especiais',
                    items: [
                        'Medicamentos para pelo menos 7 dias',
                        'Itens para bebes, idosos e pessoas com mobilidade reduzida',
                        'Oculos, baterias de aparelhos e carregadores',
                        'Plano de apoio para pessoas vulneraveis',
                    ],
                },
                {
                    title: 'Treino e comunidade',
                    items: [
                        'Exercicios simples de evacuacao e comunicacao',
                        'Mapa de vizinhos, habilidades e recursos',
                        'Pontos de encontro e rotas alternativas',
                        'Funcoes definidas por equipe',
                    ],
                },
            ],
            resilienceChecklists: [
                {
                    title: 'Energia',
                    items: [
                        'Mapa de fontes e tomadas',
                        'Priorizar comunicacao',
                        'Separar combustiveis',
                        'Turnos de recarga',
                    ],
                },
                {
                    title: 'Agua',
                    items: [
                        'Filtrar e ferver',
                        'Reservatorios fechados',
                        'Separar agua de limpeza',
                        'Controle de distribuicao',
                    ],
                },
                {
                    title: 'Comunicacao',
                    items: [
                        'Canal oficial e horarios',
                        'Quadro de avisos local',
                        'Registro de ocorrencias',
                        'Mensagens curtas e claras',
                    ],
                },
            ],
            survivalTopics: [
                {
                    title: 'Agua e higiene',
                    items: [
                        'Separar agua potavel e de limpeza',
                        'Filtrar, ferver ou tratar agua antes de beber',
                        'Criar area de higiene para evitar contaminacao',
                    ],
                },
                {
                    title: 'Abrigo e clima',
                    items: [
                        'Buscar areas elevadas e ventiladas',
                        'Isolar do chao com cobertores ou madeira',
                        'Evitar estruturas com rachaduras',
                    ],
                },
                {
                    title: 'Seguranca comunitaria',
                    items: [
                        'Turnos de vigilancia',
                        'Controle de acesso a areas criticas',
                        'Registro de entradas e saidas',
                    ],
                },
                {
                    title: 'Saude e bem-estar',
                    items: [
                        'Monitorar sinais de choque e hipotermia',
                        'Separar area de triagem e descanso',
                        'Priorizar apoio emocional e informacao clara',
                    ],
                },
                {
                    title: 'Saneamento e residuos',
                    items: [
                        'Separar lixo organico e seco',
                        'Definir area de descarte e limpeza',
                        'Manter agua e alimentos longe de contaminacao',
                    ],
                },
            ],
            femaPreparedness: [
                {
                    title: 'O que sao',
                    items: [
                        'Apoiam o desenvolvimento, manutencao e entrega de capacidades essenciais',
                        'Foco em prevencao, protecao, mitigacao, resposta e recuperacao',
                        'Voltados a estados, territorios, tribos e parceiros locais',
                    ],
                },
                {
                    title: 'Programas citados',
                    items: [
                        'Assistance to Firefighters Grants (inclui FP&S e SAFER)',
                        'Emergency Management Baseline Assessment Grant Program (EMBAG)',
                        'Emergency Management Performance Grant (EMPG)',
                    ],
                },
                {
                    title: 'Recursos e gestao',
                    items: [
                        'Fact sheets, boletins informativos e estrutura de preparacao',
                        'Oportunidades de financiamento e orientacoes oficiais',
                        'Sistema ND Grants para gestao de submissoes',
                    ],
                },
                {
                    title: 'Dados da pagina',
                    items: [
                        'Desde 2002, mais de US$ 58 bi em preparedness grants',
                        'NOFOs FY2023 totalizando mais de US$ 2 bi',
                        'Ultima atualizacao indicada: 20 fev 2024',
                    ],
                },
            ],
            playbooks: [
                {
                    id: 'isolamento',
                    title: 'Bairro isolado',
                    summary: 'Acesso interrompido, comunicacao fraca e recursos limitados.',
                    communications: [
                        'Defina canal oficial e horarios de chamada',
                        'Use formato padrao: quem chama, local, situacao, necessidades',
                        'Repita coordenadas e confirme recebimento',
                        'Mensagens curtas, objetivas e sem ruido',
                        'Evite dados pessoais; use IDs e pontos de referencia',
                        'Use horario 24h e confirme proxima atualizacao',
                    ],
                    priority: [
                        'Definir ponto de encontro seguro e sinalizado',
                        'Organizar lideranca local e turnos',
                        'Mapear pessoas desaparecidas e necessidades',
                        'Isolar areas de risco',
                    ],
                    safety: [
                        'Nao atravesse agua corrente acima do joelho',
                        'Evite fios caidos e estruturas instaveis',
                        'Use luvas e botas para remover entulho',
                    ],
                    coordination: [
                        'Equipe de comunicacao e registro',
                        'Equipe de busca e resgate leve',
                        'Equipe de agua, alimentos e energia',
                    ],
                },
                {
                    id: 'inundacao',
                    title: 'Chuva torrencial e inundacao',
                    summary: 'Risco de agua contaminada e deslocamento rapido.',
                    communications: [
                        'Defina canal oficial e horarios de chamada',
                        'Use formato padrao: quem chama, local, situacao, necessidades',
                        'Repita coordenadas e confirme recebimento',
                        'Mensagens curtas, objetivas e sem ruido',
                        'Evite dados pessoais; use IDs e pontos de referencia',
                        'Use horario 24h e confirme proxima atualizacao',
                    ],
                    priority: [
                        'Mover pessoas para pontos mais altos',
                        'Desligar energia das areas alagadas',
                        'Criar rotas seguras e sinalizadas',
                        'Abrir abrigo temporario seco',
                    ],
                    safety: [
                        'Agua de enchente pode conter esgoto e combustivel',
                        'Nao atravesse correnteza',
                        'Evite caixas eletricas molhadas',
                    ],
                    coordination: [
                        'Equipe de agua potavel',
                        'Equipe de abrigo e cobertores',
                        'Equipe de limpeza e desinfeccao',
                    ],
                },
                {
                    id: 'deslizamento',
                    title: 'Deslizamento',
                    summary: 'Encosta instavel com risco de novos eventos.',
                    communications: [
                        'Defina canal oficial e horarios de chamada',
                        'Use formato padrao: quem chama, local, situacao, necessidades',
                        'Repita coordenadas e confirme recebimento',
                        'Mensagens curtas, objetivas e sem ruido',
                        'Evite dados pessoais; use IDs e pontos de referencia',
                        'Use horario 24h e confirme proxima atualizacao',
                    ],
                    priority: [
                        'Evacuar imediatamente areas com rachaduras',
                        'Bloquear vias abaixo da encosta',
                        'Mapear casas atingidas e pessoas',
                        'Criar perimetro de seguranca',
                    ],
                    safety: [
                        'Nao entre em area de escorregamento recente',
                        'Observe sinais de novos movimentos',
                        'Use protecao ocular e capacete',
                    ],
                    coordination: [
                        'Equipe de avaliacao de risco',
                        'Equipe de busca visual',
                        'Equipe de suporte ao abrigo',
                    ],
                },
                {
                    id: 'apagao',
                    title: 'Apagao',
                    summary: 'Baixa visibilidade, comunicacao e energia limitadas.',
                    communications: [
                        'Defina canal oficial e horarios de chamada',
                        'Use formato padrao: quem chama, local, situacao, necessidades',
                        'Repita coordenadas e confirme recebimento',
                        'Mensagens curtas, objetivas e sem ruido',
                        'Evite dados pessoais; use IDs e pontos de referencia',
                        'Use horario 24h e confirme proxima atualizacao',
                    ],
                    priority: [
                        'Priorizar cargas criticas',
                        'Organizar microgeracao e baterias',
                        'Definir ponto de recarga comunitario',
                        'Evitar deslocamentos noturnos',
                    ],
                    safety: [
                        'Nao use geradores em local fechado',
                        'Evite sobrecarga em extensoes improvisadas',
                        'Mantenha combustiveis longe do calor',
                    ],
                    coordination: [
                        'Equipe de energia e combustiveis',
                        'Equipe de comunicacao e registro',
                        'Equipe de seguranca noturna',
                    ],
                },
                {
                    id: 'incendio',
                    title: 'Incendio urbano ou florestal',
                    summary: 'Fumaca densa e propagacao rapida.',
                    communications: [
                        'Defina canal oficial e horarios de chamada',
                        'Use formato padrao: quem chama, local, situacao, necessidades',
                        'Repita coordenadas e confirme recebimento',
                        'Mensagens curtas, objetivas e sem ruido',
                        'Evite dados pessoais; use IDs e pontos de referencia',
                        'Use horario 24h e confirme proxima atualizacao',
                    ],
                    priority: [
                        'Definir rotas de evacuacao sem fumaca',
                        'Cortar energia e gas da area',
                        'Criar ponto de triagem',
                        'Mapear focos ativos',
                    ],
                    safety: [
                        'Nao entrar em locais com fumaca densa',
                        'Use pano umido para filtrar o ar',
                        'Nunca use agua em incendio eletrico',
                    ],
                    coordination: [
                        'Equipe de evacuacao',
                        'Equipe de controle de acesso',
                        'Equipe de apoio medico',
                    ],
                },
                {
                    id: 'colapso',
                    title: 'Estrutura colapsada',
                    summary: 'Risco de novos desabamentos e resgate leve.',
                    communications: [
                        'Defina canal oficial e horarios de chamada',
                        'Use formato padrao: quem chama, local, situacao, necessidades',
                        'Repita coordenadas e confirme recebimento',
                        'Mensagens curtas, objetivas e sem ruido',
                        'Evite dados pessoais; use IDs e pontos de referencia',
                        'Use horario 24h e confirme proxima atualizacao',
                    ],
                    priority: [
                        'Isolar a area e criar perimetro',
                        'Priorizar resgate com risco controlado',
                        'Registrar vitimas e locais de busca',
                        'Chamar reforcos quando possivel',
                    ],
                    safety: [
                        'Nao remover pilares estruturais',
                        'Use capacete e luvas',
                        'Evite barulho excessivo ao buscar sinais',
                    ],
                    coordination: [
                        'Equipe de busca',
                        'Equipe de apoio medico',
                        'Equipe de logistica',
                    ],
                },
                {
                    id: 'preparacao',
                    title: 'Preparacao comunitaria',
                    summary: 'Planejamento antes da crise para reduzir danos.',
                    communications: [
                        'Defina canal oficial e horarios de chamada',
                        'Use formato padrao: quem chama, local, situacao, necessidades',
                        'Repita coordenadas e confirme recebimento',
                        'Mensagens curtas, objetivas e sem ruido',
                        'Evite dados pessoais; use IDs e pontos de referencia',
                        'Use horario 24h e confirme proxima atualizacao',
                    ],
                    priority: [
                        'Mapear riscos locais e pessoas vulneraveis',
                        'Definir ponto de encontro e rotas alternativas',
                        'Montar kits e inventario comunitario',
                        'Treinar comunicacao e turnos',
                    ],
                    safety: [
                        'Armazenar combustiveis com ventilacao',
                        'Evitar improvisar ligacoes eletricas',
                        'Proteger documentos e medicamentos da umidade',
                    ],
                    coordination: [
                        'Comite comunitario de crise',
                        'Equipe de comunicacao e informacao',
                        'Equipe de logistica e suprimentos',
                    ],
                },
            ],
            resources: [
                {
                    id: 'solar',
                    label: 'Painel solar',
                    actions: [
                        'Priorizar roteador mesh, radio e iluminacao',
                        'Organizar recarga por turnos',
                        'Separar cargas criticas',
                    ],
                },
                {
                    id: 'bateria',
                    label: 'Baterias e powerbanks',
                    actions: [
                        'Desligar telas e apps nao essenciais',
                        'Reservar carga para comunicacao',
                        'Rotacionar recarga por grupos',
                    ],
                },
                {
                    id: 'radio',
                    label: 'Radio VHF/UHF',
                    actions: [
                        'Definir canal oficial e horarios',
                        'Mensagens curtas e padronizadas',
                        'Evitar dados pessoais',
                    ],
                },
                {
                    id: 'ferramentas',
                    label: 'Ferramentas manuais',
                    actions: [
                        'Separar por tipo: corte, alavanca, escora',
                        'Usar protecao ocular e luvas',
                        'Registrar uso e devolucao',
                    ],
                },
                {
                    id: 'agua',
                    label: 'Acesso a agua',
                    actions: [
                        'Filtrar e ferver antes de beber',
                        'Separar agua de limpeza e consumo',
                        'Armazenar em recipientes fechados',
                    ],
                },
                {
                    id: 'abrigo',
                    label: 'Lonas e abrigo',
                    actions: [
                        'Escolher local seguro, ventilado e elevado',
                        'Isolar do chao com lonas ou madeira',
                        'Separar area de descanso e triagem',
                    ],
                },
                {
                    id: 'higiene',
                    label: 'Higiene e saneamento',
                    actions: [
                        'Montar ponto de lavagem de maos',
                        'Separar residuos e definir descarte',
                        'Proteger agua e alimentos de contaminacao',
                    ],
                },
                {
                    id: 'cozinha',
                    label: 'Cozinha comunitaria',
                    actions: [
                        'Centralizar preparo para economizar combustivel',
                        'Separar alimentos crus e cozidos',
                        'Controlar estoque e porcoes',
                    ],
                },
                {
                    id: 'mapas',
                    label: 'Mapas e sinalizacao',
                    actions: [
                        'Marcar rotas seguras e pontos de apoio',
                        'Usar placas simples e visiveis',
                        'Atualizar informacoes com horario',
                    ],
                },
            ],
            injuries: [
                {
                    id: 'sangramento',
                    label: 'Sangramento',
                    steps: [
                        'Compressao direta',
                        'Elevar membro se possivel',
                        'Manter pressao continua',
                    ],
                },
                {
                    id: 'fratura',
                    label: 'Fratura',
                    steps: [
                        'Imobilizar sem forcar alinhamento',
                        'Evitar mover sem suporte',
                        'Monitorar dor e inchaco',
                    ],
                },
                {
                    id: 'queimadura',
                    label: 'Queimadura',
                    steps: [
                        'Resfriar com agua limpa',
                        'Nao aplicar oleos caseiros',
                        'Cobrir com pano limpo e seco',
                    ],
                },
                {
                    id: 'hipotermia',
                    label: 'Hipotermia',
                    steps: [
                        'Remover roupas molhadas',
                        'Aquecer com cobertores',
                        'Oferecer liquidos quentes se consciente',
                    ],
                },
                {
                    id: 'desidratacao',
                    label: 'Desidratacao',
                    steps: [
                        'Oferecer agua potavel em pequenas quantidades',
                        'Evitar esforco excessivo no calor',
                        'Monitorar tontura e fraqueza',
                    ],
                },
            ],
        },
    },
    en: {
        portal: {
            text: {
                metaTitle: 'Resgate SOS',
                metaDescription:
                    'Offline-first platform for emergency communication and coordination.',
                languageSelector: 'Language',
                languageAuto: 'Auto (location)',
                languageFallback: 'Showing English content for this language.',
                heroEyebrow: 'Resgate SOS • crisis portal',
                heroTitle: 'Connected community even without Internet.',
                heroLead:
                    'Offline mesh network to save lives in natural disasters, urban chaos, and total isolation. Each server node becomes a hotspot, distributes all system versions, and hosts a local portal.',
                heroActions: {
                    downloads: 'Download versions',
                    assistant: 'See offline assistant',
                },
                heroBadges: ['Offline-first', 'Multi-medium mesh', 'Local minimal AI', 'Local portal'],
                panelTitle: 'Node status',
                panelLabels: {
                    edition: 'Edition',
                    mode: 'Mode',
                    http: 'HTTP',
                    mesh: 'Mesh',
                },
                panelMode: 'Local server',
                panelFooter: 'Share this portal via local Wi-Fi or cable.',
                howItWorksTitle: 'How it works in chaos scenarios',
                howItWorksLead:
                    'The system creates a local mesh between phones, desktops, TVs, and wearables. Even without Internet, the community shares messages, maps, and alerts.',
                assistantTitle: 'Offline assistant (minimal AI)',
                assistantLead:
                    'No cloud dependency. The local assistant delivers checklists, first aid, and rapid build guidance. It runs on the server and is embedded in this portal.',
                assistantSimTitle: 'Quick simulator',
                assistantScenarioLabel: 'Scenario',
                assistantResourcesLabel: 'Available resources',
                assistantInjuriesLabel: 'Observed injuries',
                assistantApiLabel: 'Local assistant API',
                assistantPrioritiesLabel: 'Priorities',
                assistantSafetyLabel: 'Safety',
                assistantCoordinationLabel: 'Coordination',
                assistantCommsLabel: 'Communication',
                assistantResourceActionsLabel: 'Actions by resource',
                assistantFirstAidLabel: 'First aid',
                assistantDisclaimer: 'Offline rule-based assistant. Does not replace professionals.',
                serverTitle: 'Server node as web host',
                serverLead:
                    'Each server node carries all system versions and publishes this local portal. The community downloads apps, consults guides, and logs events without Internet.',
                serverRunTitle: 'Run the server',
                serverRunNote:
                    'Use SOS_WEB_ROOT, SOS_HTTP_PORT, and SOS_MESH_PORT to configure via environment.',
                serverOffersTitle: 'What the node offers',
                serverOffers: [
                    'Local portal with downloads and guides',
                    'Offline assistant API',
                    'Quick registry of victims and resources',
                    'Update distribution within the network',
                ],
                telemetry: {
                    title: 'Offline telemetry',
                    lead:
                        'Track usage, mesh health, and critical events without Internet. Data stays local and can be exported.',
                    statusTitle: 'Telemetry status',
                    statusLabel: 'Status',
                    statusLoading: 'Loading',
                    statusReady: 'Active',
                    statusUnavailable: 'Unavailable',
                    eventsLabel: 'Stored events',
                    nodesLabel: 'Distinct nodes',
                    rangeLabel: 'Range',
                    typesTitle: 'Most frequent types',
                    emptyTypes: 'No data yet',
                    note:
                        'Available when the portal is served by the local Java Server. Use /telemetry/export for CSV.',
                    errorNote: 'Unable to load local telemetry.',
                },
                techTitle: 'Full communication compatibility',
                techLead:
                    'Resgate SOS was designed to be a large hotspot. Each point is a cross-node of technologies: Wi-Fi, BLE, Ethernet, and future radio, satellite, and optical modules.',
                techCards: [
                    {
                        title: 'Operational today',
                        items: [
                            'Mesh overlay with routing',
                            'Wi-Fi mDNS + TCP',
                            'Bluetooth LE',
                            'Offline web portal',
                        ],
                    },
                    {
                        title: 'Expanding',
                        items: [
                            'Bluetooth Classic and Mesh',
                            'LoRa / LoRaWAN',
                            'Optical and acoustic',
                            'VHF/UHF radio',
                        ],
                    },
                    {
                        title: 'Full vision',
                        items: [
                            'Sat D2D and non-terrestrial networks',
                            'Emergency IoT (sensors)',
                            'Microgrids and PLC',
                            'Local broadcast (ATSC/DVB/ISDB)',
                        ],
                    },
                ],
                downloadsTitle: 'Offline downloads',
                downloadsLead:
                    'All editions are available on the server node. Download and install quickly on each device.',
                downloadsNote:
                    'Windows: use the ZIP and run the .exe inside the extracted folder.',
                checklistsTitle: 'Resilience checklists',
                checklistsLead:
                    'Use as a quick guide to organize the community within a few hours.',
                commsTitle: 'Phonetic codes and communication',
                commsLead:
                    'Standardize calls to reduce noise. Use simple language, confirmation, and internationally recognized codes.',
                commsProtocolsTitle: 'Essential protocols',
                phoneticTitle: 'Phonetic alphabet',
                phoneticNote: 'Use to spell names, streets, IDs, and coordinates.',
                prepTitle: 'Preparation before the crisis',
                prepLead:
                    'Planning and a basic kit reduce risk in scenarios like floods, prolonged blackout, and isolation.',
                femaTitle: 'FEMA information (Preparedness Grants)',
                femaLead:
                    'Offline summary based on the official preparedness grants page, focusing on programs, resources, and funding notices.',
                femaNote1:
                    'Source: FEMA.gov (Preparedness Grants). Check for updates when online.',
                femaNote2:
                    'Reuse: FEMA notes most content is public domain, but some materials may have copyrights and specific credit.',
                survivalTitle: 'Survival topics in crises',
                survivalLead:
                    'Prioritize water, shelter, hygiene, and community safety. Adjust actions to local climate and risk.',
                safetyTitle: 'Safety and limits',
                safetyLead:
                    "Resgate SOS accelerates community coordination but does not replace professional responders. Always prioritize people's safety.",
                safetyItems: [
                    'Offline rule-based assistant',
                    'Avoid invasive procedures without training',
                    'Record events to improve response',
                    'Share only essential information',
                ],
            },
            downloads: {
                targets: {
                    android: 'Android Mobile',
                    tv: 'TV Box',
                    wear: 'Wear OS',
                },
                windowsZip: 'Windows (ZIP)',
                javaZip: 'Java Node (ZIP)',
                javaJar: 'Java Node (JAR)',
            },
            quickStart: [
                {
                    title: '1. Activate the server node',
                    text: 'Turn on the Java Server and share the local portal with everyone.',
                },
                {
                    title: '2. Announce the support point',
                    text: 'Define a safe location, water, power, and triage.',
                },
                {
                    title: '3. Register people and resources',
                    text: 'Use the portal to list injured, missing, and supplies.',
                },
                {
                    title: '4. Distribute tasks',
                    text: 'Organize teams by communication, power, water, and rescue.',
                },
            ],
            commsBasics: [
                'Define the official channel and call windows',
                'Use the standard format: caller, location, situation, needs',
                'Repeat coordinates and confirm receipt',
                'Keep messages short, objective, and noise-free',
                'Avoid personal data; use IDs and landmarks',
                'Use 24h time and confirm next update',
            ],
            phoneticAlphabet: [
                { letter: 'A', code: 'Alfa' },
                { letter: 'B', code: 'Bravo' },
                { letter: 'C', code: 'Charlie' },
                { letter: 'D', code: 'Delta' },
                { letter: 'E', code: 'Echo' },
                { letter: 'F', code: 'Foxtrot' },
                { letter: 'G', code: 'Golf' },
                { letter: 'H', code: 'Hotel' },
                { letter: 'I', code: 'India' },
                { letter: 'J', code: 'Juliett' },
                { letter: 'K', code: 'Kilo' },
                { letter: 'L', code: 'Lima' },
                { letter: 'M', code: 'Mike' },
                { letter: 'N', code: 'November' },
                { letter: 'O', code: 'Oscar' },
                { letter: 'P', code: 'Papa' },
                { letter: 'Q', code: 'Quebec' },
                { letter: 'R', code: 'Romeo' },
                { letter: 'S', code: 'Sierra' },
                { letter: 'T', code: 'Tango' },
                { letter: 'U', code: 'Uniform' },
                { letter: 'V', code: 'Victor' },
                { letter: 'W', code: 'Whiskey' },
                { letter: 'X', code: 'X-ray' },
                { letter: 'Y', code: 'Yankee' },
                { letter: 'Z', code: 'Zulu' },
            ],
            commsCodes: [
                {
                    title: 'International priority',
                    items: [
                        'MAYDAY = grave and immediate danger',
                        'PAN-PAN = urgency without immediate danger',
                        'SECURITE = safety advisory',
                    ],
                },
                {
                    title: 'Help request format',
                    items: [
                        'Caller + clear location',
                        'What happened and active risks',
                        'Number of people and conditions',
                        'Available resources and primary need',
                    ],
                },
                {
                    title: 'SITREP (quick report)',
                    items: [
                        '1) Current situation',
                        '2) Location and routes',
                        '3) People affected',
                        '4) Resources and failures',
                        '5) Urgent needs',
                        '6) Next update',
                    ],
                },
                {
                    title: 'Code note',
                    items: ['10-codes and Q-codes vary by region', 'Always confirm the standard with the team'],
                },
            ],
            preparednessChecklist: [
                {
                    title: 'Essential kit',
                    items: [
                        'Drinking water for at least 72h',
                        'Non-perishable food and manual can opener',
                        'Flashlights, batteries, and chargers',
                        'First aid kit and medications',
                        'Copies of documents and contacts',
                    ],
                },
                {
                    title: 'Family plan',
                    items: [
                        'Defined meeting point',
                        'Out-of-area contacts',
                        'Alternative evacuation routes',
                        'List of vulnerable people',
                    ],
                },
                {
                    title: 'Power and communication',
                    items: [
                        'Solar panel or ventilated generator',
                        'VHF/UHF radio and spare batteries',
                        'Offline maps and support points',
                        'Team identifiers',
                    ],
                },
                {
                    title: 'Documents and finances',
                    items: [
                        'Physical and digital copies of documents',
                        'List of essential contacts and addresses',
                        'Cash on hand for emergencies',
                        'Prescriptions and basic medical history',
                    ],
                },
                {
                    title: 'Health and special needs',
                    items: [
                        'Medications for at least 7 days',
                        'Items for babies, elders, and people with reduced mobility',
                        'Glasses, device batteries, and chargers',
                        'Support plan for vulnerable people',
                    ],
                },
                {
                    title: 'Training and community',
                    items: [
                        'Simple evacuation and communication drills',
                        'Map of neighbors, skills, and resources',
                        'Meeting points and alternative routes',
                        'Defined roles by team',
                    ],
                },
            ],
            resilienceChecklists: [
                {
                    title: 'Power',
                    items: [
                        'Map sources and outlets',
                        'Prioritize communication',
                        'Separate fuels',
                        'Charging shifts',
                    ],
                },
                {
                    title: 'Water',
                    items: [
                        'Filter and boil',
                        'Sealed reservoirs',
                        'Separate cleaning water',
                        'Distribution control',
                    ],
                },
                {
                    title: 'Communication',
                    items: [
                        'Official channel and schedules',
                        'Local notice board',
                        'Incident log',
                        'Short, clear messages',
                    ],
                },
            ],
            survivalTopics: [
                {
                    title: 'Water and hygiene',
                    items: [
                        'Separate drinking and cleaning water',
                        'Filter, boil, or treat water before drinking',
                        'Create a hygiene area to prevent contamination',
                    ],
                },
                {
                    title: 'Shelter and weather',
                    items: [
                        'Seek elevated and ventilated areas',
                        'Insulate from the ground with blankets or wood',
                        'Avoid structures with cracks',
                    ],
                },
                {
                    title: 'Community safety',
                    items: [
                        'Guard shifts',
                        'Access control to critical areas',
                        'Entry and exit logs',
                    ],
                },
                {
                    title: 'Health and wellbeing',
                    items: [
                        'Monitor for shock and hypothermia signs',
                        'Separate triage and rest areas',
                        'Prioritize emotional support and clear information',
                    ],
                },
                {
                    title: 'Sanitation and waste',
                    items: [
                        'Separate organic and dry waste',
                        'Define disposal and cleaning area',
                        'Keep water and food away from contamination',
                    ],
                },
            ],
            femaPreparedness: [
                {
                    title: 'What they are',
                    items: [
                        'Support the development, sustainment, and delivery of core capabilities',
                        'Focus on prevention, protection, mitigation, response, and recovery',
                        'Aimed at states, territories, tribes, and local partners',
                    ],
                },
                {
                    title: 'Programs cited',
                    items: [
                        'Assistance to Firefighters Grants (includes FP&S and SAFER)',
                        'Emergency Management Baseline Assessment Grant Program (EMBAG)',
                        'Emergency Management Performance Grant (EMPG)',
                    ],
                },
                {
                    title: 'Resources and management',
                    items: [
                        'Fact sheets, information bulletins, and preparedness framework',
                        'Funding opportunities and official guidance',
                        'ND Grants system for submission management',
                    ],
                },
                {
                    title: 'Page data',
                    items: [
                        'Since 2002, more than US$ 58B in preparedness grants',
                        'FY2023 NOFOs totaling more than US$ 2B',
                        'Last update listed: Feb 20, 2024',
                    ],
                },
            ],
            playbooks: [
                {
                    id: 'isolamento',
                    title: 'Isolated neighborhood',
                    summary: 'Access interrupted, weak communication, and limited resources.',
                    communications: [
                        'Define the official channel and call windows',
                        'Use the standard format: caller, location, situation, needs',
                        'Repeat coordinates and confirm receipt',
                        'Keep messages short, objective, and noise-free',
                        'Avoid personal data; use IDs and landmarks',
                        'Use 24h time and confirm next update',
                    ],
                    priority: [
                        'Define a safe and marked meeting point',
                        'Organize local leadership and shifts',
                        'Map missing people and needs',
                        'Isolate risk areas',
                    ],
                    safety: [
                        'Do not cross running water above the knee',
                        'Avoid downed wires and unstable structures',
                        'Use gloves and boots to remove debris',
                    ],
                    coordination: [
                        'Communication and registry team',
                        'Light search and rescue team',
                        'Water, food, and energy team',
                    ],
                },
                {
                    id: 'inundacao',
                    title: 'Heavy rain and flooding',
                    summary: 'Risk of contaminated water and fast displacement.',
                    communications: [
                        'Define the official channel and call windows',
                        'Use the standard format: caller, location, situation, needs',
                        'Repeat coordinates and confirm receipt',
                        'Keep messages short, objective, and noise-free',
                        'Avoid personal data; use IDs and landmarks',
                        'Use 24h time and confirm next update',
                    ],
                    priority: [
                        'Move people to higher ground',
                        'Shut off power in flooded areas',
                        'Create safe, marked routes',
                        'Open a dry temporary shelter',
                    ],
                    safety: [
                        'Flood water may contain sewage and fuel',
                        'Do not cross currents',
                        'Avoid wet electrical boxes',
                    ],
                    coordination: [
                        'Drinking water team',
                        'Shelter and blankets team',
                        'Cleaning and disinfection team',
                    ],
                },
                {
                    id: 'deslizamento',
                    title: 'Landslide',
                    summary: 'Unstable slope with risk of new events.',
                    communications: [
                        'Define the official channel and call windows',
                        'Use the standard format: caller, location, situation, needs',
                        'Repeat coordinates and confirm receipt',
                        'Keep messages short, objective, and noise-free',
                        'Avoid personal data; use IDs and landmarks',
                        'Use 24h time and confirm next update',
                    ],
                    priority: [
                        'Evacuate immediately areas with cracks',
                        'Block roads below the slope',
                        'Map affected homes and people',
                        'Create a safety perimeter',
                    ],
                    safety: [
                        'Do not enter recent slide areas',
                        'Watch for signs of new movements',
                        'Use eye protection and helmet',
                    ],
                    coordination: [
                        'Risk assessment team',
                        'Visual search team',
                        'Shelter support team',
                    ],
                },
                {
                    id: 'apagao',
                    title: 'Power outage',
                    summary: 'Low visibility, communication, and limited power.',
                    communications: [
                        'Define the official channel and call windows',
                        'Use the standard format: caller, location, situation, needs',
                        'Repeat coordinates and confirm receipt',
                        'Keep messages short, objective, and noise-free',
                        'Avoid personal data; use IDs and landmarks',
                        'Use 24h time and confirm next update',
                    ],
                    priority: [
                        'Prioritize critical loads',
                        'Organize microgeneration and batteries',
                        'Define a community charging point',
                        'Avoid night travel',
                    ],
                    safety: [
                        'Do not use generators indoors',
                        'Avoid overload on improvised extensions',
                        'Keep fuels away from heat',
                    ],
                    coordination: [
                        'Energy and fuels team',
                        'Communication and registry team',
                        'Night security team',
                    ],
                },
                {
                    id: 'incendio',
                    title: 'Urban or forest fire',
                    summary: 'Dense smoke and rapid spread.',
                    communications: [
                        'Define the official channel and call windows',
                        'Use the standard format: caller, location, situation, needs',
                        'Repeat coordinates and confirm receipt',
                        'Keep messages short, objective, and noise-free',
                        'Avoid personal data; use IDs and landmarks',
                        'Use 24h time and confirm next update',
                    ],
                    priority: [
                        'Define evacuation routes without smoke',
                        'Cut power and gas in the area',
                        'Create a triage point',
                        'Map active hotspots',
                    ],
                    safety: [
                        'Do not enter areas with dense smoke',
                        'Use a damp cloth to filter air',
                        'Never use water on electrical fires',
                    ],
                    coordination: [
                        'Evacuation team',
                        'Access control team',
                        'Medical support team',
                    ],
                },
                {
                    id: 'colapso',
                    title: 'Collapsed structure',
                    summary: 'Risk of new collapses and light rescue.',
                    communications: [
                        'Define the official channel and call windows',
                        'Use the standard format: caller, location, situation, needs',
                        'Repeat coordinates and confirm receipt',
                        'Keep messages short, objective, and noise-free',
                        'Avoid personal data; use IDs and landmarks',
                        'Use 24h time and confirm next update',
                    ],
                    priority: [
                        'Isolate the area and create a perimeter',
                        'Prioritize rescue with controlled risk',
                        'Register victims and search locations',
                        'Call for reinforcements when possible',
                    ],
                    safety: [
                        'Do not remove structural pillars',
                        'Use helmet and gloves',
                        'Avoid excessive noise when searching for signs',
                    ],
                    coordination: [
                        'Search team',
                        'Medical support team',
                        'Logistics team',
                    ],
                },
                {
                    id: 'preparacao',
                    title: 'Community preparation',
                    summary: 'Planning before crisis to reduce damage.',
                    communications: [
                        'Define the official channel and call windows',
                        'Use the standard format: caller, location, situation, needs',
                        'Repeat coordinates and confirm receipt',
                        'Keep messages short, objective, and noise-free',
                        'Avoid personal data; use IDs and landmarks',
                        'Use 24h time and confirm next update',
                    ],
                    priority: [
                        'Map local risks and vulnerable people',
                        'Define meeting point and alternative routes',
                        'Build kits and community inventory',
                        'Train communication and shifts',
                    ],
                    safety: [
                        'Store fuels with ventilation',
                        'Avoid improvised electrical wiring',
                        'Protect documents and medicines from humidity',
                    ],
                    coordination: [
                        'Community crisis committee',
                        'Communication and information team',
                        'Logistics and supplies team',
                    ],
                },
            ],
            resources: [
                {
                    id: 'solar',
                    label: 'Solar panel',
                    actions: [
                        'Prioritize mesh router, radio, and lighting',
                        'Organize charging by shifts',
                        'Separate critical loads',
                    ],
                },
                {
                    id: 'bateria',
                    label: 'Batteries and powerbanks',
                    actions: [
                        'Turn off non-essential screens and apps',
                        'Reserve charge for communication',
                        'Rotate charging by groups',
                    ],
                },
                {
                    id: 'radio',
                    label: 'VHF/UHF radio',
                    actions: [
                        'Define official channel and schedules',
                        'Short, standardized messages',
                        'Avoid personal data',
                    ],
                },
                {
                    id: 'ferramentas',
                    label: 'Manual tools',
                    actions: [
                        'Separate by type: cutting, leverage, shoring',
                        'Use eye protection and gloves',
                        'Record use and return',
                    ],
                },
                {
                    id: 'agua',
                    label: 'Water access',
                    actions: [
                        'Filter and boil before drinking',
                        'Separate cleaning and drinking water',
                        'Store in sealed containers',
                    ],
                },
                {
                    id: 'abrigo',
                    label: 'Tarps and shelter',
                    actions: [
                        'Choose a safe, ventilated, elevated location',
                        'Insulate from the ground with tarps or wood',
                        'Separate rest and triage areas',
                    ],
                },
                {
                    id: 'higiene',
                    label: 'Hygiene and sanitation',
                    actions: [
                        'Set up a handwashing point',
                        'Separate waste and define disposal',
                        'Protect water and food from contamination',
                    ],
                },
                {
                    id: 'cozinha',
                    label: 'Community kitchen',
                    actions: [
                        'Centralize cooking to save fuel',
                        'Separate raw and cooked food',
                        'Control stock and portions',
                    ],
                },
                {
                    id: 'mapas',
                    label: 'Maps and signage',
                    actions: [
                        'Mark safe routes and support points',
                        'Use simple, visible signs',
                        'Update information with time',
                    ],
                },
            ],
            injuries: [
                {
                    id: 'sangramento',
                    label: 'Bleeding',
                    steps: [
                        'Direct compression',
                        'Elevate limb if possible',
                        'Maintain continuous pressure',
                    ],
                },
                {
                    id: 'fratura',
                    label: 'Fracture',
                    steps: [
                        'Immobilize without forcing alignment',
                        'Avoid moving without support',
                        'Monitor pain and swelling',
                    ],
                },
                {
                    id: 'queimadura',
                    label: 'Burn',
                    steps: [
                        'Cool with clean water',
                        'Do not apply home oils',
                        'Cover with clean, dry cloth',
                    ],
                },
                {
                    id: 'hipotermia',
                    label: 'Hypothermia',
                    steps: [
                        'Remove wet clothing',
                        'Warm with blankets',
                        'Offer warm liquids if conscious',
                    ],
                },
                {
                    id: 'desidratacao',
                    label: 'Dehydration',
                    steps: [
                        'Offer drinking water in small amounts',
                        'Avoid excessive effort in heat',
                        'Monitor dizziness and weakness',
                    ],
                },
            ],
        },
    },
};
