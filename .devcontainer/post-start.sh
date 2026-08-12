# Jekyll setup

export MAKEFLAGS=-j1


echo "=== System setup starting ==="
sudo apt-get update || true
sudo apt-get install -y build-essential || true
echo "=== System setup completed ==="

echo "=== Bundle install starting ==="
bundle install
echo "=== Bundle install completed ==="

echo "=== Jekyll build starting ==="
bundle exec jekyll build
JEKYLL_EXIT=$?
echo "=== Jekyll build completed ==="

if [ $JEKYLL_EXIT -ne 0 ]; then
  echo "Jekyll build failed with exit code $JEKYLL_EXIT"
  exit $JEKYLL_EXIT
fi
