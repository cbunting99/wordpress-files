@echo off
REM WordPress Development Server Management Script

if "%1"=="start" (
    echo Starting WordPress development server...
    docker compose up -d
    echo WordPress is starting up. It will be available at http://localhost:8080
    echo Admin login: admin / admin123
    echo User Dashboard: http://localhost:8080/wp-admin
    goto :eof
)

if "%1"=="start-prod" (
    echo Starting WordPress server (production mode - no dev mounts)...
    docker compose -f docker-compose.prod.yml up -d
    echo WordPress is starting up. It will be available at http://localhost:8080
    echo Admin login: admin / admin123
    echo User Dashboard: http://localhost:8080/wp-admin
    goto :eof
)

if "%1"=="stop" (
    echo Stopping WordPress development server...
    docker compose down
    docker compose -f docker-compose.prod.yml down 2>nul
    goto :eof
)

if "%1"=="restart" (
    echo Restarting WordPress development server...
    docker compose restart
    goto :eof
)

if "%1"=="rebuild" (
    echo Rebuilding WordPress development server (preserving data)...
    docker compose down
    docker compose up --build -d
    goto :eof
)

if "%1"=="rebuild-prod" (
    echo Rebuilding WordPress server in production mode (preserving data)...
    docker compose -f docker-compose.prod.yml down
    docker compose -f docker-compose.prod.yml up --build -d
    goto :eof
)

if "%1"=="reset" (
    echo WARNING: This will delete all WordPress data and start fresh!
    set /p confirm="Are you sure? (y/N): "
    if /i "%confirm%"=="y" (
        echo Resetting WordPress development server...
        docker compose down -v
        docker compose -f docker-compose.prod.yml down -v 2>nul
        docker volume rm wpdevserver_wordpress_data wpdevserver_mysql_data 2>nul
        docker compose up --build -d
        echo WordPress has been reset. Fresh installation available at http://localhost:8080
    ) else (
        echo Reset cancelled.
    )
    goto :eof
)

if "%1"=="logs" (
    echo Showing WordPress development server logs...
    docker compose logs -f
    goto :eof
)

if "%1"=="shell" (
    echo Opening shell in WordPress container...
    docker exec -it wordpress bash
    goto :eof
)

if "%1"=="wp" (
    shift
    echo Running WP-CLI command: wp %*
    docker exec -it wordpress wp %* --allow-root
    goto :eof
)

echo WordPress Development Server Management
echo.
echo Usage: %0 {start^|start-prod^|stop^|restart^|rebuild^|rebuild-prod^|reset^|logs^|shell^|wp}
echo.
echo Commands:
echo   start       - Start development server (with file mounts)
echo   start-prod  - Start production server (files baked into container)
echo   stop        - Stop the server
echo   restart     - Restart the development server
echo   rebuild     - Rebuild development container (preserves data)
echo   rebuild-prod- Rebuild production container (preserves data)
echo   reset       - Reset everything (deletes all data)
echo   logs        - Show server logs
echo   shell       - Open bash shell in container
echo   wp          - Run WP-CLI commands
echo.
echo Examples:
echo   %0 start
echo   %0 start-prod
echo   %0 wp user list
echo   %0 wp plugin install contact-form-7
