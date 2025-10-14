@echo off
echo Testing redirect for iPhone XR...
echo.

echo USER AGENT: Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/141.0.0.0
echo.

echo Test commands for iPhone XR:
echo 1. curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/141.0.0.0" http://localhost:8000/index.html
echo.

echo Expected result: Should redirect to index_mobile_ios_test.html
echo.

pause
