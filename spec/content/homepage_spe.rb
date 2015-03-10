describe "Homepage" do
  let(:content) do
    YAML::load_file(File.join(__dir__, '../content_definitions.yml'))
  end

  before do
    visit '/'
  end

  it 'should have a header' do
    page.should have_selector 'header'
  end

  describe "Header" do
    it "should have a menu" do
      page.should have_selector 'header nav'
    end

    describe "Menu" do
      it "should have a link to access the book" do
        page.should have_selector 'nav .login'
      end

      it "should have an excerpt link" do
        page.should have_selector 'nav .excerpt'
      end

      it 'should have a buy link' do
        page.should have_selector 'nav .buy'
      end

      it "should have a support link" do
        page.should have_selector 'nav .support'
      end

      it "should have a github link" do
        page.should have_selector 'nav .github'
      end
    end

    it "should have a title" do
      visit '/'
      page.should have_selector '.title'
    end

    it "should have a hook" do
      page.should have_selector '.tagline'
    end

    describe "Tagline" do
      it "should burn the tongue" do
        content['tagline']['burnt_tongue'].should equal true
      end

      it "should tell a story about helpers" do
        content['tagline']['has_story'].should equal true
      end
    end
  end

  it "should have a intro and cover secion" do
    page.should have_selector '.intro-and-cover'
  end

  describe "Intro and Cover Section" do
    it "should have a intro" do
      page.should have_selector '.intro-and-cover .intro'
    end

    describe "Intro" do
      it "should tell first then hook at end" do
        content['intro']['tells_then_hooks'].should equal true
      end

      it "should tell about eldr" do
        content['intro']['eldr'].should equal true
      end

      it "should tell about raw mvc" do
        content['intro']['raw_mvc'].should equal true
      end

      it "should end with the start of a story about including helpers" do
        content['intro']['helpers_story'].should equal true
      end

      it "should have excerpt links" do
        visit '/'
        page.should have_selector '.btn.excerpt'
      end

      it "should have a call to action" do
        visit '/'
        page.should have_selector '.intro .btn.buy'
      end
    end

    it "should have a cover" do
      page.should have_selector '.cover'
    end
  end

  it "should loop" do
    content['has_loop'].should == true
  end

  it "should have why this book" do
    visit '/'
    page.should have_selector 'section.why'
  end

  describe "why this book section" do
    it "should burn the tongue" do
      content['section_why']['has_burnt_tongue'].should == true
    end

    it "should make the reader feel the fustration of not knowing how their framework works" do
      content['section_why']['make_reader_feel'].should == true
    end

    it "should tell the story of the helpers" do
      content['section_why']['has_story'].should == true
    end

    it "should talk about the internals of rack" do
      content['section_why']['really_learn_rack'].should == true
    end

    it "should mention internals of rails, sinatra, raw MVC and eldr" do
      content['section_why']['mentions_internals'].should == true
    end

    it "should loop back to helpers" do
      content['section_why']['has_loop'].should == true
    end
  end

  it "should have a what you will build section" do
    visit '/'
    page.should have_selector 'section.what'
  end

  describe "build section" do
    it "should mention raw mvc app" do
      content['section_what']['mentions_raw_mvc'].should == true
    end

    it "should mention eldr" do
      content['section_what']['mentions_eldr'].should == true
    end

    it "should mention this site" do
      content['section_what']['mentions_this_site'].should == true
    end
  end

  it "should have a you get section" do
    visit '/'
    page.should have_selector 'section.get'
  end

  describe "you get section" do
    describe "screenshots" do
      it "should show book" do
        page.should have_selector '.get .screenshots .book'
      end

      it "should show sources" do
        page.should have_selector '.get .screenshots .sources'
      end
    end

    it "should mention chapters count" do
      page.should have_selector '.get .chapters'
    end

    it "should mention code commits" do
      page.should have_selector '.get .list .sources'
    end
  end

  it "should have a table of contents" do
    visit '/'
    page.should have_selector 'section.get ul.table-of-contetns'
  end

  it "should have a packages section" do
    visit '/'
    page.should have_selector 'section.packages'
  end

  describe "packages section" do
    describe "$35" do
      it "should include the book" do
        visit '/'
        page.should have_selector 'section.packages > .ultra .includes > .book'
      end
    end

    describe "$45" do
      it "should include the book" do
        visit '/'
        page.should have_selector 'section.packages > .super-ultra .includes > .book'
      end

      it "should include a screencast on building a TODOS app" do
        visit '/'
        page.should have_selector 'section.packages > .super-ultra .includes > .screencast-todos'
      end
    end

    describe "$75" do
      it "should include the book" do
        visit '/'
        page.should have_selector 'section.packages > .super-ultra-mega .includes > .book'
      end

      it "should include a screencast on building a TODOS app" do
        visit '/'
        page.should have_selector 'section.packages > .super-ultra-mega .includes > .screencast-todos'
      end

      it "should include bonus chapters" do
        visit '/'
        page.should have_selector '.super-ultra-mega .bonus-chapters'
      end

      describe "bonus chapters" do
        it "should include a bonus chapter on rack streaming" do
          visit '/'
          page.should have_selector '.super-ultra-mega .bonus-chapters .rack-streaming'
        end

        it "should include a bonus chapter on building a streaming chess app" do
          visit '/'
          page.should have_selector '.super-ultra-mega .streaming-chess'
        end

        it "should include a bonus chapter on rack as client model" do
          visit '/'
          page.should have_selector '.super-ultra-mega .bonus-chapters .faraday'
        end

        it "should include a bonus chapter on building sprockects middleware" do
          visit '/'
          page.should have_selector '.super-ultra-mega .bonus-chapters .sprockets-clone'
        end

        it "should include a bonus chapter on building a grape like framework" do
          visit '/'
          page.should have_selector '.super-ultra-mega .bonus-chapters .building-grape'
        end

        it "should include a bonus chapter on security" do
          visit '/'
          page.should have_selector '.super-ultra-mega .bonus-chapters .security'
        end

        it "should include a bonus chapter on structuring rack apps" do
          visit '/'
          page.should have_selector '.super-ultra-mega .bonus-chapters .structuring-rack-apps'
        end
      end
    end
  end

  it "should have a footer" do
    visit '/'
    page.should have_selector 'footer'
  end

  describe "Footer" do
    it "should have copyright" do
      page.should have_selector 'footer .copyright'
    end
  end
end
