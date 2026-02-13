package com.resgatesos.server;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class AssistantEngine {
    public static final String VERSION = "1.1";

    private static final Map<String, Playbook> PLAYBOOKS = new LinkedHashMap<>();
    private static final Map<String, ResourceHint> RESOURCES = new LinkedHashMap<>();
    private static final Map<String, InjuryHint> INJURIES = new LinkedHashMap<>();
    private static final List<String> COMMS_BASICS = list(
            "Defina canal oficial e horarios de chamada",
            "Use formato padrao: quem chama, local, situacao, necessidades",
            "Repita coordenadas e confirme recebimento",
            "Mensagens curtas e objetivas",
            "Evite dados pessoais; use IDs e pontos de referencia",
            "Use horario 24h e confirme proxima atualizacao"
    );
    private static final List<Map<String, Object>> COMMS_CODES = new ArrayList<>();
    private static final List<Map<String, String>> PHONETIC = new ArrayList<>();
    private static final List<Map<String, Object>> PREPAREDNESS = new ArrayList<>();
    private static final List<Map<String, Object>> SURVIVAL = new ArrayList<>();

    static {
        PLAYBOOKS.put("isolamento", new Playbook(
                "isolamento",
                "Bairro isolado / vias interrompidas",
                "Comunidade sem acesso, mobilidade e informacao",
                list(
                        "Definir ponto de encontro seguro e visivel",
                        "Criar lideranca local e turnos por area",
                        "Mapear pessoas desaparecidas e necessidades criticas",
                        "Isolar areas de risco (fios, lama, estruturas instaveis)"
                ),
                list(
                        "Nao atravesse agua corrente acima do joelho",
                        "Evite fios caidos ou postes inclinados",
                        "Nao entre em estruturas com rachaduras ou cheiro de gas",
                        "Use luvas e botas ao remover entulho"
                ),
                list(
                        "Ativar nos SOS e fixar estacao central no local seguro",
                        "Divulgar canal/ID do servidor local e quadro de avisos",
                        "Registrar voluntarios e pontos de apoio no portal local"
                ),
                list(
                        "Abrir rota de passagem com sinalizacao simples",
                        "Montar abrigo seco e ventilado com barreira contra chuva",
                        "Organizar estoque comum por categorias"
                ),
                list(
                        "Checagem rapida de sinais vitais e risco de choque",
                        "Parar sangramento com compressao direta",
                        "Imobilizar suspeita de fratura antes de mover"
                ),
                list(
                        "Equipe de comunicacao",
                        "Equipe de busca e resgate leve",
                        "Equipe de agua e alimentos",
                        "Equipe de energia e manutencao"
                ),
                list(
                        "Lista de pessoas",
                        "Mapa do bairro e rotas seguras",
                        "Pontos de agua e energia",
                        "Inventario de suprimentos"
                )
        ));
        PLAYBOOKS.put("preparacao", new Playbook(
                "preparacao",
                "Preparacao comunitaria",
                "Planejamento antes da crise para reduzir danos e acelerar resposta",
                list(
                        "Mapear riscos locais e pessoas vulneraveis",
                        "Definir ponto de encontro e rotas alternativas",
                        "Montar kits e inventario comunitario",
                        "Treinar comunicacao, evacuacao e turnos"
                ),
                list(
                        "Armazenar combustiveis com ventilacao",
                        "Evitar improvisar ligacoes eletricas",
                        "Proteger documentos e medicamentos da umidade",
                        "Manter extintores e lanternas acessiveis"
                ),
                list(
                        "Definir canal oficial e contatos de emergencia",
                        "Treinar SITREP e mensagens curtas",
                        "Atualizar quadro de avisos periodicamente"
                ),
                list(
                        "Preparar area de estoque seca e organizada",
                        "Separar abrigo, triagem e descanso",
                        "Sinalizar rotas e pontos de apoio"
                ),
                list(
                        "Conferir kit de primeiros socorros",
                        "Checar validade de medicamentos",
                        "Registrar alergias e necessidades especiais"
                ),
                list(
                        "Comite comunitario de crise",
                        "Equipe de comunicacao e informacao",
                        "Equipe de logistica e suprimentos"
                ),
                list(
                        "Inventario de recursos",
                        "Mapa de rotas e pontos de apoio",
                        "Calendario de exercicios"
                )
        ));

        PLAYBOOKS.put("inundacao", new Playbook(
                "inundacao",
                "Chuva torrencial / inundacao",
                "Riscos de agua contaminada e isolamento rapido",
                list(
                        "Mover pessoas para pontos mais altos",
                        "Desligar energia nas areas alagadas",
                        "Criar rotas seguras e impedir travessias perigosas",
                        "Ativar equipe de resgate local"
                ),
                list(
                        "Nunca atravesse agua com correnteza",
                        "Agua de enchente pode ter esgoto e combustivel",
                        "Evite contato com caixas de energia molhadas",
                        "Nao deixe criancas perto de valas ou canais"
                ),
                list(
                        "Estabelecer pontos de aviso por mesh e quadros",
                        "Registrar locais de abrigo temporario",
                        "Atualizar nivel da agua a cada 30 minutos"
                ),
                list(
                        "Montar abrigo seco com camadas isolantes",
                        "Criar area de secagem e higienizacao",
                        "Armazenar agua potavel em recipientes fechados"
                ),
                list(
                        "Tratar hipotermia: cobrir e remover roupas molhadas",
                        "Lavar feridas com agua limpa e sabao",
                        "Monitorar sinais de infeccao"
                ),
                list(
                        "Equipe de agua potavel",
                        "Equipe de abrigo e cobertores",
                        "Equipe de limpeza e desinfeccao"
                ),
                list(
                        "Pontos seguros elevados",
                        "Risco de deslizamento proximo",
                        "Estoques de agua, cobertores e alimentos"
                )
        ));

        PLAYBOOKS.put("deslizamento", new Playbook(
                "deslizamento",
                "Deslizamento / encosta instavel",
                "Solo instavel com risco de novos eventos",
                list(
                        "Evacuar imediatamente areas com rachaduras",
                        "Bloquear vias abaixo de encostas instaveis",
                        "Mapear casas atingidas e desaparecidos",
                        "Ativar equipe de resgate leve"
                ),
                list(
                        "Nao entre em area de escorregamento recente",
                        "Observe sinais de novos movimentos de terra",
                        "Use capacete e protecao ocular ao remover entulho"
                ),
                list(
                        "Concentrar comunicacao em um ponto alto",
                        "Registrar ocorrencias por setor",
                        "Atualizar quadro de riscos a cada hora"
                ),
                list(
                        "Criar barreiras simples para conter lama",
                        "Cobrir drenagens para reduzir erosao",
                        "Definir areas de abrigo longe da encosta"
                ),
                list(
                        "Imobilizar vitimas antes de mover",
                        "Evitar mover sem apoio se suspeita de trauma",
                        "Manter vias aereas livres e observar consciencia"
                ),
                list(
                        "Equipe de avaliacao de risco",
                        "Equipe de busca visual",
                        "Equipe de suporte a abrigo"
                ),
                list(
                        "Mapa de encostas e casas afetadas",
                        "Lista de vitimas e feridos",
                        "Rota de evacuacao segura"
                )
        ));

        PLAYBOOKS.put("apagao", new Playbook(
                "apagao",
                "Apagao / falta de energia",
                "Baixa visibilidade e comunicacao limitada",
                list(
                        "Priorizar cargas criticas e iluminar pontos-chave",
                        "Montar microrede com solar e baterias",
                        "Carregar radios e celulares por turnos",
                        "Evitar deslocamentos noturnos sem iluminacao"
                ),
                list(
                        "Nao usar geradores em local fechado",
                        "Evitar sobrecarga em extensoes improvisadas",
                        "Manter combustiveis longe de fontes de calor"
                ),
                list(
                        "Montar ponto de comunicacao com energia",
                        "Manter atualizacoes periodicas de status",
                        "Registrar necessidades e prioridades"
                ),
                list(
                        "Criar area iluminada para triagem e apoio",
                        "Organizar fila de recarga de baterias",
                        "Separar combustiveis e fontes de calor"
                ),
                list(
                        "Monitorar desidratacao e hipotermia",
                        "Evitar cozinhar em locais fechados",
                        "Manter kit de primeiros socorros acessivel"
                ),
                list(
                        "Equipe de energia e combustiveis",
                        "Equipe de comunicacao e registro",
                        "Equipe de seguranca noturna"
                ),
                list(
                        "Inventario de baterias e paines",
                        "Locais com energia ativa",
                        "Pontos de recarga"
                )
        ));

        PLAYBOOKS.put("incendio", new Playbook(
                "incendio",
                "Incendio urbano ou florestal",
                "Risco de fumaca e propagacao rapida",
                list(
                        "Definir rotas de evacuacao sem fumaca",
                        "Cortar energia e gas da area",
                        "Criar ponto de encontro e triagem",
                        "Mapear focos ativos"
                ),
                list(
                        "Nao entrar em locais com fumaça densa",
                        "Evitar inalacao direta, use pano umido",
                        "Nunca use agua em incendio eletrico"
                ),
                list(
                        "Atualizar status de rotas em tempo real",
                        "Registrar pessoas evacuadas",
                        "Manter comunicacao curta e objetiva"
                ),
                list(
                        "Isolar materiais combustiveis",
                        "Criar aceiros simples se houver vegetacao",
                        "Preparar area de suporte"
                ),
                list(
                        "Resfriar queimaduras com agua corrente por minutos",
                        "Cobrir queimaduras com pano limpo",
                        "Nao estourar bolhas"
                ),
                list(
                        "Equipe de evacuacao",
                        "Equipe de controle de acesso",
                        "Equipe de apoio medico"
                ),
                list(
                        "Rotas de fuga",
                        "Lista de pessoas evacuadas",
                        "Pontos de agua e extintores"
                )
        ));

        PLAYBOOKS.put("colapso", new Playbook(
                "colapso",
                "Estrutura colapsada / resgate leve",
                "Risco de novos desabamentos",
                list(
                        "Isolar area e estabelecer perimetro de seguranca",
                        "Priorizar resgate com risco controlado",
                        "Chamar reforcos profissionais se possivel",
                        "Registrar vitimas e locais de busca"
                ),
                list(
                        "Nao remova pilares estruturais",
                        "Use capacete e luvas",
                        "Evite barulho excessivo ao buscar sinais"
                ),
                list(
                        "Designar operador de comunicacao",
                        "Marcar areas ja verificadas",
                        "Manter registro de sobreviventes"
                ),
                list(
                        "Criar corredores de acesso",
                        "Estabilizar entulho com apoio improvisado",
                        "Separar ferramentas por tipo"
                ),
                list(
                        "Checar respiracao e hemorragias",
                        "Imobilizar e reduzir movimento",
                        "Evitar retirar vitimas presas sem plano"
                ),
                list(
                        "Equipe de busca",
                        "Equipe de apoio medico",
                        "Equipe de logistica"
                ),
                list(
                        "Mapa de setores",
                        "Lista de vitimas",
                        "Inventario de ferramentas"
                )
        ));

        RESOURCES.put("solar", new ResourceHint(
                "solar",
                "Painel solar / microgeracao",
                list(
                        "Priorizar roteador mesh, radio e iluminacao",
                        "Organizar recarga por turnos e etiquetas",
                        "Separar cargas criticas (comunicacao e saude)"
                )
        ));
        RESOURCES.put("bateria", new ResourceHint(
                "bateria",
                "Baterias e powerbanks",
                list(
                        "Desligar telas e apps nao essenciais",
                        "Reservar carga para comunicacao e lanternas",
                        "Rotacionar recarga por grupos"
                )
        ));
        RESOURCES.put("radio", new ResourceHint(
                "radio",
                "Radio VHF/UHF ou comunicacao local",
                list(
                        "Definir canal oficial e horarios de chamada",
                        "Manter mensagens curtas e padronizadas",
                        "Evitar transmitir informacoes pessoais"
                )
        ));
        RESOURCES.put("ferramentas", new ResourceHint(
                "ferramentas",
                "Ferramentas manuais",
                list(
                        "Separar por tipo: corte, alavanca, escora",
                        "Usar protecao ocular e luvas",
                        "Registrar quem esta usando cada ferramenta"
                )
        ));
        RESOURCES.put("agua", new ResourceHint(
                "agua",
                "Acesso a agua (mesmo nao potavel)",
                list(
                        "Filtrar e ferver antes de beber",
                        "Adicionar gotas de hipoclorito conforme orientacao",
                        "Separar agua para limpeza e para consumo"
                )
        ));
        RESOURCES.put("abrigo", new ResourceHint(
                "abrigo",
                "Abrigo e lonas",
                list(
                        "Escolher local seguro, ventilado e elevado",
                        "Isolar do chao com lonas ou madeira",
                        "Separar area de descanso e triagem"
                )
        ));
        RESOURCES.put("higiene", new ResourceHint(
                "higiene",
                "Higiene e saneamento",
                list(
                        "Montar ponto de lavagem de maos",
                        "Separar residuos e definir descarte",
                        "Proteger agua e alimentos de contaminacao"
                )
        ));
        RESOURCES.put("cozinha", new ResourceHint(
                "cozinha",
                "Cozinha comunitaria",
                list(
                        "Centralizar preparo para economizar combustivel",
                        "Separar alimentos crus e cozidos",
                        "Controlar estoque e porcoes"
                )
        ));
        RESOURCES.put("mapas", new ResourceHint(
                "mapas",
                "Mapas e sinalizacao",
                list(
                        "Marcar rotas seguras e pontos de apoio",
                        "Usar placas simples e visiveis",
                        "Atualizar informacoes com horario"
                )
        ));

        INJURIES.put("sangramento", new InjuryHint(
                "sangramento",
                "Sangramento",
                list(
                        "Aplicar compressao direta",
                        "Elevar membro se possivel",
                        "Se sangramento persistir, compressao continuada"
                )
        ));
        INJURIES.put("fratura", new InjuryHint(
                "fratura",
                "Fratura",
                list(
                        "Imobilizar sem forcar alinhamento",
                        "Evitar mover sem suporte",
                        "Monitorar dor e inchaco"
                )
        ));
        INJURIES.put("queimadura", new InjuryHint(
                "queimadura",
                "Queimadura",
                list(
                        "Resfriar com agua limpa por alguns minutos",
                        "Nao aplicar oleos ou pomadas caseiras",
                        "Cobrir com pano limpo e seco"
                )
        ));
        INJURIES.put("hipotermia", new InjuryHint(
                "hipotermia",
                "Hipotermia",
                list(
                        "Remover roupas molhadas",
                        "Aquecer com cobertores e isolamento do chao",
                        "Oferecer liquidos quentes se consciente"
                )
        ));
        INJURIES.put("desidratacao", new InjuryHint(
                "desidratacao",
                "Desidratacao",
                list(
                        "Oferecer agua potavel em pequenas quantidades",
                        "Evitar esforco excessivo no calor",
                        "Monitorar tontura e fraqueza"
                )
        ));

        COMMS_CODES.add(group("Prioridade internacional", list(
                "MAYDAY = perigo grave e imediato",
                "PAN-PAN = urgencia sem risco imediato",
                "SECURITE = aviso de seguranca"
        )));
        COMMS_CODES.add(group("Formato de pedido de ajuda", list(
                "Quem chama + localizacao clara",
                "O que aconteceu e riscos ativos",
                "Quantidade de pessoas e condicoes",
                "Recursos disponiveis e necessidade principal"
        )));
        COMMS_CODES.add(group("SITREP (relatorio rapido)", list(
                "1) Situacao atual",
                "2) Localizacao e rotas",
                "3) Pessoas afetadas",
                "4) Recursos e falhas",
                "5) Necessidades urgentes",
                "6) Proxima atualizacao"
        )));
        COMMS_CODES.add(group("Nota sobre codigos", list(
                "Codigos 10 e Q variam por regiao",
                "Sempre confirme o padrao com a equipe"
        )));

        PHONETIC.add(phonetic("A", "Alfa"));
        PHONETIC.add(phonetic("B", "Bravo"));
        PHONETIC.add(phonetic("C", "Charlie"));
        PHONETIC.add(phonetic("D", "Delta"));
        PHONETIC.add(phonetic("E", "Echo"));
        PHONETIC.add(phonetic("F", "Foxtrot"));
        PHONETIC.add(phonetic("G", "Golf"));
        PHONETIC.add(phonetic("H", "Hotel"));
        PHONETIC.add(phonetic("I", "India"));
        PHONETIC.add(phonetic("J", "Juliett"));
        PHONETIC.add(phonetic("K", "Kilo"));
        PHONETIC.add(phonetic("L", "Lima"));
        PHONETIC.add(phonetic("M", "Mike"));
        PHONETIC.add(phonetic("N", "November"));
        PHONETIC.add(phonetic("O", "Oscar"));
        PHONETIC.add(phonetic("P", "Papa"));
        PHONETIC.add(phonetic("Q", "Quebec"));
        PHONETIC.add(phonetic("R", "Romeo"));
        PHONETIC.add(phonetic("S", "Sierra"));
        PHONETIC.add(phonetic("T", "Tango"));
        PHONETIC.add(phonetic("U", "Uniform"));
        PHONETIC.add(phonetic("V", "Victor"));
        PHONETIC.add(phonetic("W", "Whiskey"));
        PHONETIC.add(phonetic("X", "X-ray"));
        PHONETIC.add(phonetic("Y", "Yankee"));
        PHONETIC.add(phonetic("Z", "Zulu"));

        PREPAREDNESS.add(group("Kit essencial", list(
                "Agua potavel para pelo menos 72h",
                "Alimentos nao pereciveis e abridor manual",
                "Lanternas, baterias e carregadores",
                "Kit de primeiros socorros e medicamentos",
                "Copias de documentos e contatos"
        )));
        PREPAREDNESS.add(group("Plano familiar", list(
                "Ponto de encontro definido",
                "Contatos fora da area",
                "Rotas alternativas de evacuacao",
                "Lista de pessoas vulneraveis"
        )));
        PREPAREDNESS.add(group("Energia e comunicacao", list(
                "Painel solar ou gerador com ventilacao",
                "Radio VHF/UHF e pilhas sobressalentes",
                "Mapas offline e pontos de apoio",
                "Identificadores de equipe"
        )));
        PREPAREDNESS.add(group("Documentos e financas", list(
                "Copias fisicas e digitais de documentos",
                "Lista de contatos e enderecos essenciais",
                "Dinheiro em especie para emergencias",
                "Receitas e historico medico basico"
        )));
        PREPAREDNESS.add(group("Saude e necessidades especiais", list(
                "Medicamentos para pelo menos 7 dias",
                "Itens para bebes, idosos e pessoas vulneraveis",
                "Oculos, baterias de aparelhos e carregadores",
                "Plano de apoio para pessoas com mobilidade reduzida"
        )));
        PREPAREDNESS.add(group("Treino e comunidade", list(
                "Exercicios simples de evacuacao e comunicacao",
                "Mapa de vizinhos, habilidades e recursos",
                "Pontos de encontro e rotas alternativas",
                "Funcoes definidas por equipe"
        )));
        PREPAREDNESS.add(group("Recursos oficiais (FEMA)", list(
                "Programas citados: AFG/FP&S/SAFER, EMBAG, EMPG",
                "Fact sheets, boletins informativos e orientacoes",
                "ND Grants para gestao de submissoes",
                "Dados da pagina: >US$ 58 bi desde 2002; FY2023 >US$ 2 bi"
        )));
        PREPAREDNESS.add(group("Avisos e creditos", list(
                "Conteudo baseado em FEMA.gov; ver atualizacoes quando online",
                "Alguns materiais podem ter direitos autorais com credito especifico"
        )));

        SURVIVAL.add(group("Agua e higiene", list(
                "Separar agua potavel e de limpeza",
                "Filtrar, ferver ou tratar agua antes de beber",
                "Criar area de higiene para evitar contaminacao"
        )));
        SURVIVAL.add(group("Abrigo e clima", list(
                "Buscar areas elevadas e ventiladas",
                "Isolar do chao com cobertores ou madeira",
                "Evitar estruturas com rachaduras"
        )));
        SURVIVAL.add(group("Seguranca comunitaria", list(
                "Turnos de vigilancia",
                "Controle de acesso a areas criticas",
                "Registro de entradas e saidas"
        )));
        SURVIVAL.add(group("Saude e bem-estar", list(
                "Monitorar sinais de choque e hipotermia",
                "Separar area de triagem e descanso",
                "Priorizar apoio emocional e informacao clara"
        )));
        SURVIVAL.add(group("Saneamento e residuos", list(
                "Separar lixo organico e seco",
                "Definir area de descarte e limpeza",
                "Manter agua e alimentos longe de contaminacao"
        )));
    }

    public static Map<String, Object> catalog() {
        List<Map<String, Object>> scenarios = new ArrayList<>();
        for (Playbook playbook : PLAYBOOKS.values()) {
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("id", playbook.id);
            entry.put("title", playbook.title);
            entry.put("summary", playbook.summary);
            scenarios.add(entry);
        }

        List<Map<String, Object>> resources = new ArrayList<>();
        for (ResourceHint hint : RESOURCES.values()) {
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("id", hint.id);
            entry.put("label", hint.label);
            resources.add(entry);
        }

        List<Map<String, Object>> injuries = new ArrayList<>();
        for (InjuryHint hint : INJURIES.values()) {
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("id", hint.id);
            entry.put("label", hint.label);
            injuries.add(entry);
        }

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("assistantVersion", VERSION);
        payload.put("scenarios", scenarios);
        payload.put("resources", resources);
        payload.put("injuries", injuries);
        payload.put("communicationsBasics", COMMS_BASICS);
        payload.put("communicationsCodes", COMMS_CODES);
        payload.put("phoneticAlphabet", PHONETIC);
        payload.put("preparedness", PREPAREDNESS);
        payload.put("survival", SURVIVAL);
        payload.put("usage", "Use /assistant?scenario=inundacao&resources=solar,radio&injuries=sangramento");
        payload.put("disclaimer",
                "Assistente offline baseado em regras. Nao substitui profissionais.");
        return payload;
    }

    public static Map<String, Object> build(Map<String, String> params) {
        String scenarioId = normalize(params.get("scenario"));
        Playbook playbook = PLAYBOOKS.containsKey(scenarioId)
                ? PLAYBOOKS.get(scenarioId)
                : PLAYBOOKS.get("isolamento");

        List<String> resources = splitList(params.get("resources"));
        List<String> injuries = splitList(params.get("injuries"));

        List<String> resourceSteps = new ArrayList<>();
        for (String resource : resources) {
            ResourceHint hint = RESOURCES.get(resource);
            if (hint != null) {
                resourceSteps.addAll(hint.actions);
            }
        }

        List<String> injurySteps = new ArrayList<>();
        for (String injury : injuries) {
            InjuryHint hint = INJURIES.get(injury);
            if (hint != null) {
                injurySteps.addAll(hint.actions);
            }
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("assistantVersion", VERSION);
        response.put("scenario", playbook.title);
        response.put("summary", playbook.summary);
        response.put("priority", playbook.priority);
        response.put("safety", playbook.safety);
        response.put("communications", playbook.communications);
        response.put("construction", playbook.construction);
        List<String> medical = new ArrayList<>(playbook.medical);
        medical.addAll(injurySteps);
        response.put("medical", medical);
        response.put("coordination", playbook.coordination);
        response.put("checklists", playbook.checklists);
        response.put("resources", resources);
        response.put("resourceActions", resourceSteps);
        response.put("injuries", injuries);
        response.put("communicationsBasics", COMMS_BASICS);
        response.put("communicationsCodes", COMMS_CODES);
        response.put("phoneticAlphabet", PHONETIC);
        response.put("preparedness", PREPAREDNESS);
        response.put("survival", SURVIVAL);
        response.put("disclaimer",
                "Assistente offline baseado em regras. Nao substitui profissionais.");
        return response;
    }

    private static String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase().replace(' ', '_');
    }

    private static List<String> splitList(String value) {
        if (value == null || value.trim().isEmpty()) {
            return new ArrayList<>();
        }
        String[] parts = value.split(",");
        List<String> items = new ArrayList<>();
        for (String part : parts) {
            String normalized = normalize(part);
            if (!normalized.isEmpty()) {
                items.add(normalized);
            }
        }
        return items;
    }

    private static List<String> list(String... items) {
        return new ArrayList<>(Arrays.asList(items));
    }

    private static Map<String, Object> group(String title, List<String> items) {
        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("title", title);
        entry.put("items", items);
        return entry;
    }

    private static Map<String, String> phonetic(String letter, String code) {
        Map<String, String> entry = new LinkedHashMap<>();
        entry.put("letter", letter);
        entry.put("code", code);
        return entry;
    }

    private static final class Playbook {
        private final String id;
        private final String title;
        private final String summary;
        private final List<String> priority;
        private final List<String> safety;
        private final List<String> communications;
        private final List<String> construction;
        private final List<String> medical;
        private final List<String> coordination;
        private final List<String> checklists;

        private Playbook(
                String id,
                String title,
                String summary,
                List<String> priority,
                List<String> safety,
                List<String> communications,
                List<String> construction,
                List<String> medical,
                List<String> coordination,
                List<String> checklists
        ) {
            this.id = id;
            this.title = title;
            this.summary = summary;
            this.priority = priority;
            this.safety = safety;
            this.communications = communications;
            this.construction = construction;
            this.medical = medical;
            this.coordination = coordination;
            this.checklists = checklists;
        }
    }

    private static final class ResourceHint {
        private final String id;
        private final String label;
        private final List<String> actions;

        private ResourceHint(String id, String label, List<String> actions) {
            this.id = id;
            this.label = label;
            this.actions = actions;
        }
    }

    private static final class InjuryHint {
        private final String id;
        private final String label;
        private final List<String> actions;

        private InjuryHint(String id, String label, List<String> actions) {
            this.id = id;
            this.label = label;
            this.actions = actions;
        }
    }
}
