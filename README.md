# WP Curso
## Desenvolvimento WP do jeito certo

# Definições de projeto
- **Nome do projeto**: WP Curso
- **Cliente**: Magenteiro
- **Versão do PHP**: 8.3
- **Versão do WP**: 6.5


# Configuração do ambiente de desenvolvimento
1. Clone o repositório do templace: `git clone git@github.com:magenteiro/wpcurso.git -b wpadv/templates/docker NOMEDOPROJETO` substituindo `NOMEDOPROJETO` pelo nome do projeto/pasta nova.
2. Acesse a pasta do projeto: `cd NOMEDOPROJETO`
3. Clone o projeto dentro da pasta `wordpress` ou da pasta desejada e mapeada em docker-compose.yml (em wordpress > volumes): `git clone <este projeto.git> wordpress`
4. Inicie o ambiente de desenvolvimento: `docker-compose up -d`
5. Acesse o container do WordPress: `docker-compose exec wordpress bash`
6. Baixe o WordPress na versão especificada: `wp core download --version=6.5 --locale=pt_BR --force`
6. Crie o arquivo de configuração do wordpress: `wp config create --dbname=wordpress --dbuser=wordpress --dbpass=wordpress --dbhost=db --locale=pt_BR`
7. Instale o WordPress: `wp core install --url=https://wordpress.test --title="WP Curso" --admin_user=admin --admin_password=admin --admin_email=seu@email.com --skip-email`