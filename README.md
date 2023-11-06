# sharding
Implementação de fragmentos de banco de dados

## Descrição

A proposta desse projeto é facilitar a abstração de volume de dados de uma tabela no período de tempo de um ano, alocando em outro banco esse fragmento de dados específico.

## Função da Procedure MySQL

Neste projeto, temos uma procedure MySQL importante chamada `make_shard()`. Ela desempenha um papel fundamental no processamento de dados no banco de dados. Abaixo, você encontrará uma descrição detalhada de suas principais funções e como utilizá-la.

### `make_shard(table_name varchar(255), sharding_year int)`

#### Descrição

A `make_shard` é responsável por criar o ambiente necessário para receber os dados de expurgo da secção a ser fracionada do banco principal

#### Parâmetros

A procedure aceita os seguintes parâmetros:

- `table_name`: É o nome da tabela que será expurgada. Esse parâmetro é do tipo varchar(255) e serve para indicar a origem dos dados.
- `sharding_year`: É o ano desejado para o fragmento. É importante que a origem possua um campo "created" do tipo "datetime" pois é a partir dele que o particionamento é realizado.

#### Exemplo de Uso

```sql
-- Exemplo de uso da procedure
CALL  make_sharding('orders', 2021);
