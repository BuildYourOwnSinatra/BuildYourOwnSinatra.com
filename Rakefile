if ENV['RACK_ENV'] == 'test'
  require 'rspec/core/rake_task'
  require 'rubocop/rake_task'

  RSpec::Core::RakeTask.new(:spec)
  RuboCop::RakeTask.new(:rubocop)

  task :default do
    Rake::Task['spec'].execute
    Rake::Task['rubocop'].execute
  end
end

task :seed do
  chapters       = ['introduction']
  bonus_chapters = ['']

  Screencast.destroy_all
  Package.destroy_all

  ##
  # Screencasts
  ##
  screencast_mvc   = Screencast.create(name: 'MVC On Rack', file: '')
  screencast_todos = Screencast.create(name: 'TODOS APP', file: '')

  ##
  # Packages
  ##
  Package.create(name: 'The Book', price: 35, slug: 'book', chapters: chapters)

  package = Package.create(name:     'The Book + Screencasts',
                           price:    45,
                           slug:     'book-and-screencasts',
                           chapters: chapters)

  package.screencasts << screencast_mvc
  package.screencasts << screencast_todos
  package.save

  package = Package.create(name:   'The Book + Screencasts + Bonus Chapters',
                           price:   55,
                           slug:    'everything',
                           chapters: chapters + bonus_chapters)

  package.screencasts << screencast_mvc
  package.screencasts << screencast_todos
  package.save
end
