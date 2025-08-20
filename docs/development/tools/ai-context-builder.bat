@echo off
REM AI Context Builder - Fixed Version with Individual Redirects
REM Usage: ai-context-builder.bat [focus_area] [task_type] [output_file]

setlocal enabledelayedexpansion

REM ripgrep (rg) should be available in system PATH

set FOCUS_AREA=%1
set TASK_TYPE=%2
set OUTPUT_FILE=%3

if "%FOCUS_AREA%"=="" set FOCUS_AREA=general
if "%TASK_TYPE%"=="" set TASK_TYPE=development
if "%OUTPUT_FILE%"=="" (
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set DATE_PART=%%c%%a%%b
    for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME_PART=%%a%%b
    set TIME_PART=!TIME_PART:~0,4!
    set OUTPUT_FILE=..\ai-contexts\ai-context-%FOCUS_AREA%-%TASK_TYPE%-!DATE_PART!-!TIME_PART!.md
)

REM Create ai-contexts directory if it doesn't exist
if not exist "..\ai-contexts" mkdir ..\ai-contexts

if "%1"=="--help" goto :help
if "%1"=="-h" goto :help

echo 🤖 Building AI Context for %FOCUS_AREA% %TASK_TYPE%
echo 📄 Output: %OUTPUT_FILE%

REM Convert relative path to absolute before changing directories
pushd %CD%
if "%OUTPUT_FILE:~1,1%"==":" (
    set ABS_OUTPUT_FILE=%OUTPUT_FILE%
) else (
    set ABS_OUTPUT_FILE=%CD%\%OUTPUT_FILE%
)
popd

REM Navigate to project root
cd ..\..\..

REM Create the file and write header
echo # AI Development Context - %FOCUS_AREA% > "%ABS_OUTPUT_FILE%"
echo Generated: %date% %time% >> "%ABS_OUTPUT_FILE%"
echo Focus: %TASK_TYPE% >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ## 🎯 Project Context >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
echo ### Current Working Directory >> "%ABS_OUTPUT_FILE%"
echo Working from: %CD% >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Package Structure >> "%ABS_OUTPUT_FILE%"
if exist "packages" (
    echo Available packages: >> "%ABS_OUTPUT_FILE%"
    dir packages /B >> "%ABS_OUTPUT_FILE%"
    echo. >> "%ABS_OUTPUT_FILE%"
)

if /i "%FOCUS_AREA%"=="component" goto :component_content
if /i "%FOCUS_AREA%"=="frontend" goto :component_content
if /i "%FOCUS_AREA%"=="api" goto :api_content
if /i "%FOCUS_AREA%"=="backend" goto :api_content
if /i "%FOCUS_AREA%"=="testing" goto :testing_content
goto :general_content

:component_content
echo ## 🎨 Frontend Development Context >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Component Architecture >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
if exist "packages\desktop-client\src\components" (
    echo **Key component directories:** >> "%ABS_OUTPUT_FILE%"
    echo ``` >> "%ABS_OUTPUT_FILE%"
    dir "packages\desktop-client\src\components" /B | powershell -Command "$input | ForEach-Object { '- ' + $_ }" >> "%ABS_OUTPUT_FILE%"
    echo ``` >> "%ABS_OUTPUT_FILE%"
    echo. >> "%ABS_OUTPUT_FILE%"
)

echo ### Available UI Components >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
if exist "packages\desktop-client\src\components\common" (
    echo **Common components:** >> "%ABS_OUTPUT_FILE%"
    echo ``` >> "%ABS_OUTPUT_FILE%"
    dir "packages\desktop-client\src\components\common" /B | powershell -Command "$input | ForEach-Object { '- ' + $_ }" >> "%ABS_OUTPUT_FILE%"
    echo ``` >> "%ABS_OUTPUT_FILE%"
    echo. >> "%ABS_OUTPUT_FILE%"
)

echo ### React Component Patterns >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
echo **Export function patterns:** >> "%ABS_OUTPUT_FILE%"
echo ```typescript >> "%ABS_OUTPUT_FILE%"
rg "export.*function" packages/desktop-client -g "*.tsx" --no-filename | powershell -Command "$input | Select-Object -First 5" >> "%ABS_OUTPUT_FILE%"
echo ``` >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

goto :task_content

:api_content
echo ## ⚙️ Backend Development Context >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### API Structure >> "%ABS_OUTPUT_FILE%"
if exist "packages\loot-core\src\server" (
    echo Server modules: >> "%ABS_OUTPUT_FILE%"
    dir "packages\loot-core\src\server" /B >> "%ABS_OUTPUT_FILE%"
    echo. >> "%ABS_OUTPUT_FILE%"
)

echo ### Database >> "%ABS_OUTPUT_FILE%"
if exist "packages\loot-core\src\server\db" (
    echo Database modules: >> "%ABS_OUTPUT_FILE%"
    dir "packages\loot-core\src\server\db" /B >> "%ABS_OUTPUT_FILE%"
    echo. >> "%ABS_OUTPUT_FILE%"
)

echo ### Handler Patterns ^(actual examples^): >> "%ABS_OUTPUT_FILE%"
rg "handlers\[.*\].*=" packages/loot-core -g "*.ts" | powershell -Command "$input | Select-Object -First 5" >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

goto :task_content

:testing_content
echo ## 🧪 Testing Development Context >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Test Structure >> "%ABS_OUTPUT_FILE%"
echo Test files can be found with *.test.ts or *.test.tsx extensions >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Testing Framework >> "%ABS_OUTPUT_FILE%"
echo Uses Vitest for testing - check package.json for test scripts >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Testing Patterns ^(actual examples^): >> "%ABS_OUTPUT_FILE%"
rg "describe\(|it\(|test\(" packages -g "*.test.ts" | powershell -Command "$input | Select-Object -First 5" >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

goto :task_content

:general_content
echo ## 🌐 General Development Context >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Project Overview >> "%ABS_OUTPUT_FILE%"
echo Actual Budget - Local-first personal finance application >> "%ABS_OUTPUT_FILE%"
echo Monorepo structure with yarn workspaces >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Recent Changes >> "%ABS_OUTPUT_FILE%"
git log --oneline -5 >> "%ABS_OUTPUT_FILE%" 2>nul
echo. >> "%ABS_OUTPUT_FILE%"

:task_content
echo ## 🎯 Task-Specific Guidance >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

if /i "%TASK_TYPE%"=="feature" (
    echo ### ✨ Feature Development >> "%ABS_OUTPUT_FILE%"
    echo - Follow existing component patterns >> "%ABS_OUTPUT_FILE%"
    echo - Add appropriate TypeScript types >> "%ABS_OUTPUT_FILE%"
    echo - Include tests for new functionality >> "%ABS_OUTPUT_FILE%"
    echo - Update relevant documentation >> "%ABS_OUTPUT_FILE%"
) else if /i "%TASK_TYPE%"=="bugfix" (
    echo ### 🐛 Bug Fix Context >> "%ABS_OUTPUT_FILE%"
    echo - Identify root cause first >> "%ABS_OUTPUT_FILE%"
    echo - Check for similar patterns in codebase >> "%ABS_OUTPUT_FILE%"
    echo - Ensure fix doesn't break existing functionality >> "%ABS_OUTPUT_FILE%"
    echo - Add regression tests >> "%ABS_OUTPUT_FILE%"
) else (
    echo ### 🛠️ Development Best Practices >> "%ABS_OUTPUT_FILE%"
    echo - Follow TypeScript strict mode >> "%ABS_OUTPUT_FILE%"
    echo - Use existing utility functions >> "%ABS_OUTPUT_FILE%"
    echo - Maintain consistent code style >> "%ABS_OUTPUT_FILE%"
    echo - Write comprehensive tests >> "%ABS_OUTPUT_FILE%"
)

echo. >> "%ABS_OUTPUT_FILE%"
echo ## 🧠 AI Prompting Strategy >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
echo ### Recommended Prompt Template: >> "%ABS_OUTPUT_FILE%"
echo ``` >> "%ABS_OUTPUT_FILE%"
echo Context: [Paste relevant sections above] >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
echo Task: %TASK_TYPE% for %FOCUS_AREA% following existing patterns >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
echo Constraints: >> "%ABS_OUTPUT_FILE%"
echo - Follow TypeScript strict mode >> "%ABS_OUTPUT_FILE%"
echo - Match existing code style and patterns >> "%ABS_OUTPUT_FILE%"
echo - Maintain test coverage >> "%ABS_OUTPUT_FILE%"
echo - Consider performance implications >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
echo Output Requirements: >> "%ABS_OUTPUT_FILE%"
echo - Implementation with file:line references >> "%ABS_OUTPUT_FILE%"
echo - Explanation of pattern choices >> "%ABS_OUTPUT_FILE%"
echo - Integration points with existing code >> "%ABS_OUTPUT_FILE%"
echo - Testing strategy >> "%ABS_OUTPUT_FILE%"
echo ``` >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ## 📚 Quick Reference >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"
echo ### Key Commands >> "%ABS_OUTPUT_FILE%"
echo - yarn test --watch=false : Run tests >> "%ABS_OUTPUT_FILE%"
echo - yarn lint : Check code style >> "%ABS_OUTPUT_FILE%"
echo - yarn typecheck : TypeScript validation >> "%ABS_OUTPUT_FILE%"
echo - yarn start:browser : Development server >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo ### Documentation >> "%ABS_OUTPUT_FILE%"
echo - docs/development/code-examples/ : Code patterns >> "%ABS_OUTPUT_FILE%"
echo - docs/development/architecture-analysis/ : Project structure >> "%ABS_OUTPUT_FILE%"
echo - docs/development/guides/ : Troubleshooting and references >> "%ABS_OUTPUT_FILE%"
echo. >> "%ABS_OUTPUT_FILE%"

echo --- >> "%ABS_OUTPUT_FILE%"
echo Generated: %date% %time% >> "%ABS_OUTPUT_FILE%"
echo Location: %OUTPUT_FILE% >> "%ABS_OUTPUT_FILE%"

REM Navigate back to tools directory
cd docs\development\tools

echo ✅ Context generated successfully!
echo 📄 File: %OUTPUT_FILE%
echo 💡 Copy relevant sections to your AI prompt
echo 🚀 Use Tree of Thoughts approach for complex tasks

goto :end

:help
echo AI Context Builder - Working Version with Real Patterns
echo.
echo Usage: %~nx0 [focus_area] [task_type] [output_file]
echo.
echo Focus Areas:
echo   component/frontend  - React component development
echo   api/backend        - API and server development  
echo   testing            - Test development
echo   general            - General development
echo.
echo Task Types:
echo   feature            - New feature development
echo   bugfix             - Bug fixing
echo   development        - General development
echo.
echo Examples:
echo   %~nx0 component feature
echo   %~nx0 api bugfix
echo   %~nx0 testing development

:end
endlocal