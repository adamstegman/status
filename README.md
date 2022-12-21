# Status

A status page for Adam Stegman.
Compiled from ERB templates and hosted on Github Pages.

## Testing

    bundle install
    bundle exec rake build
    ( cd _site; python3 -m http.server 8000 & )
    open http://localhost:8000

## Deployment

    bundle install
    bundle exec rake 'site:publish["adamstegman/status"]' CNAME=status.adamstegman.com

## Development of the builder

    bundle install
    bundle exec rspec
