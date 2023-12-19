# frozen_string_literal: true

require 'uri'
module Legacy
  class SocialId < Legacy::BaseCv
    # TODO: add tag dependent validation
    self.table_name = 'research_ids'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :social_ids

    RESEARCH_IDS = {
      # https://orcid.org/0000-0002-1825-0097
      'orcid' => {
        'img' => 'ORCIDiD_icon16x16.png',
        'url' => 'https://orcid.org/XXX',
        'label' => 'ORCID',
        'order' => 0,
        'icon' => nil,
        're' => /^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}$/,
        'help' => {
          'en' => 'https://orcid-integration.epfl.ch/',
          'fr' => 'https://orcid-integration.epfl.ch/'
        }
      },
      # https://www.webofscience.com/wos/author/rid/AAX-5119-2020
      'wos' => {
        'img' => 'publons.png',
        'url' => 'https://www.webofscience.com/wos/author/rid/XXX',
        'label' => 'Publons - Web of Science ID',
        'order' => 1,
        'icon' => nil,
        're' => /^([A-Z]+-[0-9]{4}-[0-9]{4}|[0-9])+$/
      },
      # https://www.scopus.com/authid/detail.uri?authorId=57192201516
      'scopus' => {
        'img' => 'scopus.png',
        'url' => 'https://www.scopus.com/authid/detail.uri?authorId=XXX',
        'label' => 'Scopus ID',
        'order' => 2,
        'icon' => nil,
        're' => /^[0-9]+$/
      },
      'googlescholar' => {
        'img' => 'google_scholar.png',
        'url' => 'https://scholar.google.com/citations?user=XXX&hl=en&oi=ao',
        # 'url' => "https://scholar.google.com/citations?user=XXX"
        'label' => 'Google Scholar ID',
        'order' => 3,
        'icon' => 'google',
        're': /^[0-9a-zA-Z.-]+$/ # TODO: check this!
      },
      'linkedin' => {
        'img' => 'linkedin.jpg',
        'url' => 'https://www.linkedin.com/in/XXX',
        'label' => 'Linkedin ID',
        'order' => 4,
        'icon' => 'linkedin',
        're' => %r{^[a-z][a-z0-9-]+/?$} # TODO: check this!
      }
    }.freeze

    def url
      @url ||= begin
        @s = RESEARCH_IDS[tag]
        @s['url'].sub('XXX', content)
      end
    end

    def icon_class
      @s ||= RESEARCH_IDS[tag]
      @s['icon'].nil? ? '' : "social-icon-#{@s['icon']}"
    end

    def icon
      @s ||= RESEARCH_IDS[tag]
      @s['icon']
    end

    def image
      @s ||= RESEARCH_IDS[tag]
      "social/#{@s['img']}"
    end

    def label
      @s ||= RESEARCH_IDS[tag]
      @s['label']
    end

    def order
      self[:ordre] || default_order
    end

    def default_order
      @s ||= RESEARCH_IDS[tag]
      @s['order']
    end

    def re
      @s ||= RESEARCH_IDS[tag]
      @s['re']
    end

    def content_ok?
      re.match?(content)
    end
  end
end

# TODO: check
# sub getResearchIDs {
#   my ($self, $sciper) = @_;
#   return unless $sciper;
#   my $dbh  = $self->{dbh};
#   my $sql = qq{select * from cv.research_ids where sciper=?};
# #    $sql .= qq{ and show='1'} unless $self->{editmode};
#   my $sth = $dbh->prepare( $sql ) or die "** ERR people prepare :$sql: $DBI::errstr\n";
#   $sth->execute ($sciper) or die "** ERR execute : $DBI::errstr\n";
#   my $researchids = $research_ids;
#   while (my $data = $sth->fetchrow_hashref ) {
#     next unless $data->{tag};
#     next unless $research_ids->{$data->{tag}};
#     utf8::decode ($data->{content});
#     $researchids->{$data->{tag}}->{id_show} = $data->{id_show};
#     $researchids->{$data->{tag}}->{content} = $data->{content};
#     $researchids->{$data->{tag}}->{ordre}   = $data->{ordre};
#     $researchids->{$data->{tag}}->{id}      = $data->{id};
#   }

#   return $researchids;

# }
