class Legacy::IsaCode < Legacy::BaseDinfo
  self.table_name = 'isa_codes'
  self.primary_key = nil

  def self.load_all_codes
    @all_codes ||= begin
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
        when "fr"
          "PEDAGO"
        when "en"
          "PEDAGOENG"
        else
          "PEDAGO"
        end
    codes[t][k]
  end

  def self.t_section(k, lang = I18n.locale)
    codes = load_all_codes
    t = case lang
        when "fr"
          "SECTION"
        when "en"
          "SECTIONENG"
        else
          "SECTION"
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

# sub getCoursData {
#    my ($self, $refUsers, $params) = @_;

#    my $langues = {
#     fr => { fr => 'fran&ccedil;ais', en => 'anglais',},
#     en => { fr => 'french',          en => 'english', },
#    };
#    my ($coursData, $byUser, $byCours);

#    my $scipers  = join ("','", @$refUsers);
#    my $lang     = $params->{lang} ;
#    my $langueens= $params->{langueens} ;
#    my $langTxt  = $lang ? $lang : 'en';
#    my $sem      = $params->{sem};
#    my $detail   = $params->{detail};
#    my $peracad  = $params->{peracad};
#    my $pedago   = $params->{pedago};
#    my $section  = $params->{section};
#    my $MAX_OBJ  = $params->{MAX_OBJ} ? $params->{MAX_OBJ} : 1024 ;
#    my $code     = $params->{code} ;

#    return unless $scipers or $section;

#    my $semTxt = {
#       ete   => {
#         fr => '&eacute;t&eacute;',
#         en => 'summer',
#       },
#       hiver => {
#         fr => 'hiver',
#         en => 'winter',
#       },
#    };

#    my $ISAPedago = $lang eq 'en' ? 'PEDAGOENG' :'PEDAGO';
#    my $ISASect   = $lang eq 'en' ? 'SECTIONENG' :'SECTION';

#    my $dbh = ORAConnect ($self, 'cours');
#    return {
#     error => 1,
#    } unless $dbh;

#    my $sql = qq{SELECT * FROM  V_ISA_KIS_COURS WHERE };
#      $sql .= qq{N_SCIPER in ('$scipers') AND }      if $scipers;
#      $sql .= qq{ C_SEMESTRE='$sem' AND }            if $sem;
#      $sql .= qq{ C_PERACAD='$peracad' AND }         if $peracad;
#      $sql .= qq{ C_SECTION='$section' AND }         if $section;
#      $sql .= qq{ C_LANGUEENS='$langueens' AND }     if $langueens;
#      $sql .= qq{ C_CODECOURS REGEXP '$code%' AND }  if $code;
#      $sql =~ s/ AND $//;
#      $sql .= qq{ order by C_CODECOURS};

#    my $sth = $dbh->prepare ($sql) or warn 'getCoursData ** ERR prepare : '.$dbh->errstr;
#    $sth->execute ()               or warn 'getCoursData ** DB execute : '.$dbh->errstr;

#    my @coursLoop;
#    my %seen;
#    while (my $DATA  = $sth->fetchrow_hashref () ) {

#       next unless $DATA->{C_LANGUE} eq $lang;

#       if ($pedago) {
#         if ($pedago eq 'PHD') {
#         next unless $DATA->{C_SECTION} =~ /^ED/;
#         } else {
#         next unless $DATA->{C_PEDAGO} =~ /^$pedago/i;
#         }
#       }
#       next if exists($seen{$DATA->{C_CODECOURS}});
#       $seen{$DATA->{C_CODECOURS}} = 1;
#       if ($MAX_OBJ) {
#         $DATA->{X_OBJECTIFS} = substr($DATA->{X_OBJECTIFS},0, $MAX_OBJ).'...' if (length($DATA->{X_OBJECTIFS}) > $MAX_OBJ)  ;
#       }
#       $DATA->{X_OBJECTIFS} = $self->sanitize($DATA->{X_OBJECTIFS});
#       $DATA->{C_SEMESTRE}  = $semTxt->{lc($DATA->{C_SEMESTRE})}->{$langTxt};
#       $DATA->{C_PEDAGO}    = $ISA_codes->{$ISAPedago}->{$DATA->{C_PEDAGO}};
#       $DATA->{C_SECTION}   = $ISA_codes->{$ISASect}->{$DATA->{C_SECTION}} ? $ISA_codes->{$ISASect}->{$DATA->{C_SECTION}} : $DATA->{C_SECTION};
#       $DATA->{X_OBJECTIFS} =~ s/\r\n/ /g;
#       $DATA->{X_OBJECTIFS} =~ s/\[b\]/<b>/g;
#       $DATA->{X_OBJECTIFS} =~ s/\[\/b\]/<\/b>/g;
#       $DATA->{X_OBJECTIFS} =~ s/\[li\]/ /g;
#       $DATA->{X_OBJECTIFS} =~ s/\[\/li\]/, /g;
#       $DATA->{X_LISTENOM}  =~ s/,/, /g;
#       $DATA->{sSemestre}   = $sem;
#       $DATA->{sShowS}      = $detail eq 'S';
#       $DATA->{sShowM}      = $detail eq 'M';

#       $DATA->{C_LANGUEENS}  = $langues->{$lang}->{$DATA->{C_LANGUEENS}};

#       my @listeScipers;
#       foreach my $sciper (sort {$usersData->{$a}->{nom} cmp $usersData->{$b}->{nom}} split (/,/, $DATA->{X_LISTESCIPER})) {
#         next unless $sciper;
#         next unless $usersData->{$sciper}->{nom};
#         if ($scipers) {
#           next unless $scipers =~ /$sciper/;
#         }
#         push @listeScipers, {
#           X_SCIPER => $sciper,
#           X_NOM  => "$usersData->{$sciper}->{nom}&nbsp;$usersData->{$sciper}->{prenom}",
#           X_MAILID => getMailID($sciper, $usersData->{$sciper}->{email}),
#           C_LANGUEENS => $langues->{$lang}->{$DATA->{C_LANGUEENS}},
#         } if $usersData->{$sciper}->{nom};
#       }

#       $DATA->{X_SCIPERLOOP}  = \@listeScipers;

#       $byUser->{$DATA->{N_SCIPER}}->{$DATA->{I_MATIERE}} = $DATA;

#       my $index = qq{$DATA->{I_MATIERE}$DATA->{C_SECTION}$DATA->{C_PEDAGO}$DATA->{C_SEMESTRE}};
#       $byCours->{$index}->{lc($DATA->{C_LANGUE})} = $DATA;
#    }

#    my (@outloop, $crtINDEX, $crtinloop , $data, $crtdata);
#    foreach my $index (sort {$a cmp $b} keys %$byCours) {
#       my $otherLang = $lang eq 'en' ? 'fr' : 'en';
#       $data = exists $byCours->{$index}->{$lang} ? $byCours->{$index}->{$lang} : $byCours->{$index}->{$otherLang};
#       my $INDEX = $data->{C_CODECOURS} ? $data->{C_CODECOURS} : $data->{X_MATIERE};
#       next unless $data->{X_MATIERE};
#       # For some reason X_OBJECTIFS (a.k.a. the description) was mandatory
#       # I make it optional but empty by default. Let's see what brakes.
#       # next unless $data->{X_OBJECTIFS};
#       $data->{X_OBJECTIFS} = " " unless $data->{X_OBJECTIFS};

#       if ($INDEX ne $crtINDEX) {
#         push @outloop, {
#         X_MATIERE   => $crtdata->{X_MATIERE},
#         X_OBJECTIFS => $crtdata->{X_OBJECTIFS},
#         X_URL       => $crtdata->{X_URL},
#         X_LISTENOM  => $crtdata->{X_LISTENOM},
#         X_LISTESCIPER=> $crtdata->{X_LISTESCIPER},
#         C_SECTION   => $crtdata->{C_SECTION},
#         C_CODECOURS => $crtdata->{C_CODECOURS},
#         C_PERACAD   => $crtdata->{C_PERACAD},
#         C_SEMESTRE  => $crtdata->{C_SEMESTRE},
#         C_PEDAGO    => $crtdata->{C_PEDAGO},
#         C_LANGUEENS => $crtdata->{C_LANGUEENS},
#         scipersLoop => $crtdata->{X_SCIPERLOOP},
#         coursLoop   => $crtinloop,
#         sSemestre   => $sem,
#         sShowS      => $detail eq 'S',
#         sShowM      => $detail eq 'M',
#       } if $crtinloop;

#       $crtINDEX = $INDEX;
#       $crtdata  = $data;
#       my @inloop;
#       $crtinloop = \@inloop;
#     }

#     push @$crtinloop, $data;

#    }

#    push @outloop, {
#     X_MATIERE   => $data->{X_MATIERE},
#     X_OBJECTIFS => $data->{X_OBJECTIFS},
#     X_URL       => $data->{X_URL},
#     X_LISTENOM  => $data->{X_LISTENOM},
#     X_LISTESCIPER=> $crtdata->{X_LISTESCIPER},
#     C_SECTION   => $crtdata->{C_SECTION},
#     C_CODECOURS => $crtdata->{C_CODECOURS},
#     C_PERACAD   => $data->{C_PERACAD},
#     C_SEMESTRE  => $data->{C_SEMESTRE},
#     C_PEDAGO    => $data->{C_PEDAGO},
#     C_LANGUEENS => $data->{C_LANGUEENS},
#     scipersLoop => $crtdata->{X_SCIPERLOOP},
#     coursLoop   => $crtinloop,
#     sSemestre   => $sem,
#     sShowS      => $detail eq 'S',
#     sShowM      => $detail eq 'M',
#    } if $crtinloop;

#    $sth->finish; $dbh->disconnect;
# #   @outloop = sort {lc($a->{X_MATIERE}) cmp lc($b->{X_MATIERE})} @outloop ;
#    @outloop = sort {lc($a->{C_CODECOURS}) cmp lc($b->{C_CODECOURS})} @outloop ;

#    return {
#     byuser  => $byUser,
#     bycours => \@outloop,
#     error => 0,
#    };

# }
