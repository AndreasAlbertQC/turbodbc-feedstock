@echo on

if not defined libarrow set "libarrow=0"
for /f "tokens=1 delims=." %%a in ("%libarrow%") do set "ARROW_MAJOR=%%a"

rem pyarrow/libarrow >= 24 headers require C++20 (std::span, std::popcount,
rem std::bit_width), but turbodbc defaults to cpp_std=c++17. Bump the standard
rem for those builds; older arrow keeps building at the upstream default.
set "EXTRA_CONFIG_SETTINGS="
if %ARROW_MAJOR% GEQ 24 set "EXTRA_CONFIG_SETTINGS=--config-settings=setup-args=-Dcpp_std=c++20"

%PYTHON% -m pip install -vv %EXTRA_CONFIG_SETTINGS% .
if errorlevel 1 exit 1
