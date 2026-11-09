# Formulários do Vistto (importados do Axyma Forms)

Cada arquivo `.json` desta pasta é um formulário do app. Ele vira uma linha da tabela
`tipos_inspecao`, com `modo = 'formulario'` e a estrutura no campo `estrutura`.
No app, aparece na pesquisa "Nova inspeção". No Painel, aparece em Checklists (somente leitura).

## Como o Axyma organiza um formulário

- **Modelo** (nome, versão, tipo de preenchimento "Logado | Hierárquico", valor máximo de scoring)
- **Itens**: as seções (ex.: IDENTIFICAÇÃO, SITUAÇÃO, DESCRIÇÃO), com peso e "ocorrência múltipla"
- **Subitens**: os campos de cada item, com:
  - nome
  - tipo de questão
  - opções (seleção ou avaliação)
  - permissões (foto, galeria, arquivo, comentário)
  - obrigatoriedades (preenchimento, foto, comentário, arquivo)

## Tipos de questão do Axyma e como ficam no app

| Axyma (valor interno)        | Vistto `tipo`  | No app                                                    |
|------------------------------|----------------|-----------------------------------------------------------|
| Texto (`textoCurto`)         | `texto`        | campo de texto; `longo: true` vira caixa grande           |
| Lista de Textos (`list`)     | `lista`        | caixa grande, um item por linha                           |
| Seleção (`unique`)           | `selecao`      | lista com busca; `multipla: true` aceita várias respostas |
| Avaliação (`avaliacao`)      | `avaliacao`    | botões (ex.: CONFORME 100 / NÃO CONFORME 0 / N/A)         |
| Data (`data`)                | `data`         | calendário                                                |
| Hora (`hora`)                | `hora`         | relógio                                                   |
| Número (`numero`)            | `numero`       | teclado numérico                                          |
| Valor/Medida (`valorMedida`) | `valorMedida`  | teclado numérico                                          |
| Assinatura (`assinatura`)    | `assinatura`   | quadro para assinar com o dedo (salva como imagem)        |
| e-mail (`email`)             | `email`        | teclado de e-mail                                         |
| Telefone (`telefone`)        | `telefone`     | teclado de telefone                                       |
| CPF/CNPJ (`cpfcnpj`)         | `cpfcnpj`      | teclado numérico                                          |
| CEP (`cep`)                  | `cep`          | teclado numérico                                          |
| Placa de carro (`placa`)     | `placa`        | texto em maiúsculas                                       |

## Formato do arquivo

```json
{
  "id": "rci", "nome": "RCI - Relatório de Condição Insegura", "descricao": "…",
  "modo": "formulario", "ordem": 3, "ativo": true, "usa_atividade": false,
  "estrutura": {
    "versao": 1,
    "origem": { "sistema": "Axyma Forms", "modelo": "…", "versao": 15, "id": "…", "lido_em": "AAAA-MM-DD" },
    "itens": [
      { "id": "1", "nome": "IDENTIFICAÇÃO", "subitens": [
        { "id": "1.1", "nome": "Local", "tipo": "texto", "longo": true, "obrigatorio": true,
          "permite": { "foto": true, "galeria": true, "comentario": true },
          "obriga": { "foto": false, "comentario": false } },
        { "id": "1.5", "nome": "Setor", "tipo": "selecao", "multipla": false, "opcoes": ["Civil", "Elétrica", "Outro: Comente"] },
        { "id": "2.5", "nome": "Foi sanada?", "tipo": "avaliacao",
          "opcoes": [{ "rotulo": "CONFORME", "valor": 100 }, { "rotulo": "NÃO CONFORME", "valor": 0 }], "na": "Não se Aplica" }
      ]}
    ]
  }
}
```

## Regras do app

- Campo com `obrigatorio: true` precisa ser respondido para enviar.
- Opção que começa com "Outro", "Outra" ou "Outros" exige comentário, quando o campo permite comentário.
- **Avaliação com valor 0** (ex.: NÃO CONFORME) abre uma NC, que segue o fluxo de NCs do app (WhatsApp para o líder, foto da correção, validação):
  - descrição da NC: o comentário do campo, ou o campo "Descrição", ou o primeiro texto longo do formulário;
  - prazo: o primeiro campo de data, ou 24 h se não houver data;
  - nesse caso, o líder/encarregado passa a ser obrigatório.
- Conformidade da inspeção: média dos valores das avaliações respondidas (N/A não conta), ou 100% se não houver avaliação.
- As fotos de cada campo vão para a tabela `fotos`. A primeira foto vira a "foto do local" da inspeção.
- O que ainda não é tratado:
  - anexo de arquivo (só foto);
  - peso de itens e scoring diferentes de 0 a 100;
  - "ocorrência múltipla" (repetir um item).
- `obriga_resp` (só em avaliação): foto/comentário obrigatórios conforme a resposta,
  igual ao Axyma (Conforme `c`, Não conforme `nc`, Não se aplica `na`). Sem ele, vale `obriga`.

## Importar um formulário novo do Axyma

1. No Axyma, abra **Gestão de Formulários › Editar** no formulário (só leitura; não salvar).
2. Em cada item, clique no olho e depois em **Abrir todos os subitens**.
3. Copie, de cada subitem: nome, tipo, opções, permissões e obrigatoriedades.
4. Crie `banco/formularios/<id>.json` neste formato e grave a linha em `tipos_inspecao`.

Lidos até agora:
- `rci.json`: RCI - Relatório de Condição Insegura (Segurança), Axyma versão 15, 16 campos. Lido em 31/10/2026.
  Ajustes de grafia: "Tipo de Resgistro" virou "Tipo de Registro" e "Paralização" virou "Paralisação".
- `extintor.json`: Inspeção de Extintor de Incêndio (SMS), 21 campos, grupo Inspeções de Campo. Lido em 09/11/2026.
  Ajustes de grafia: "Selo do IMETRO" virou "Selo do Inmetro", "HA EXISTÊNCIA DE PLACAS" virou "Há placas indicativas?",
  "DESOBSTRÍDO" virou "desobstruído", "ESTA E PERFEITO ESTADO" virou "está em perfeito estado".
