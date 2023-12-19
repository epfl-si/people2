# frozen_string_literal: true

module Legacy
  class IsaCode < Legacy::BaseDinfo
    self.table_name = 'isa_codes'
    self.primary_key = nil

    def self.load_all_codes
      @load_all_codes ||= begin
        cc = {
          'SECTION' => {},
          'SECTIONEN' => {},
          'PEDAGO' => {},
          'PEDAGOEN' => {}
        }
        where(type: %w[SECTION SECTIONENG PEDAGO PEDAGOENG]).each do |c|
          cc[c.type][c.code] = c.libelle
        end
        cc
      end
    end

    def self.t_pedago(k, lang = I18n.locale)
      codes = load_all_codes
      t = case lang
          when 'fr'
            'PEDAGO'
          when 'en'
            'PEDAGOENG'
          else
            'PEDAGO'
          end
      codes[t][k]
    end

    def self.t_section(k, lang = I18n.locale)
      codes = load_all_codes
      t = case lang
          when 'fr'
            'SECTION'
          when 'en'
            'SECTIONENG'
          else
            'SECTION'
          end
      codes[t][k]
    end

    # def self.pedagos_by_code(lang=I18n.locale)
    #   t = case lang
    #       when "fr"
    #         "PEDAGO"
    #       when "en"
    #         "PEDAGOENG"
    #       else
    #         "PEDAGO"
    #       end
    #   where(type: t).map{|c| [c.code, c.libelle]}.to_h
    # end
    # def self.sections_by_code(lang=I18n.locale)
    #   t = case lang
    #       when "fr"
    #         "SECTION"
    #       when "en"
    #         "SECTIONENG"
    #       else
    #         "SECTION"
    #       end
    #   where(type: t).map{|c| [c.code, c.libelle]}.to_h
    # end

    #    my $ISA_codes;
    #    my $sql = qq{select * from dinfo.isa_codes where type in ('SECTION','SECTIONENG','PEDAGO','PEDAGOENG')};
    #    my $sth = $self->{dbh}->query($sql);
    #    while (my $data = $sth->fetchrow_hashref) {
    #     $ISA_codes->{$data->{type}}->{$data->{code}} = $data->{libelle};
    #    }
    # def self.labels_by_type_code()
    #   cc={}
    #   where(type: ['SECTION','SECTIONENG','PEDAGO','PEDAGOENG']).each do |c|
    #     cc[c.type] ||= {}
    #     cc[c.type][c.code] = c.libelle
    #   end
    #   cc
    # end
  end
end
