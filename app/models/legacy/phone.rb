class Legacy::Phone < Legacy::BaseBottin
  self.table_name = 'annuaire_phones'
  self.primary_key = 'phone_id'

  default_scope do
    where("annuaire_phones.valid_from < ? AND (annuaire_phones.valid_to > ? OR annuaire_phones.valid_to IS NULL)",
          DateTime.now, DateTime.now)
  end

  def number
    phone_nb
  end

  def category
    phone_type
  end
end

# sub getPersonPhones {
#     my ($self, $pers_id) = @_;
#     return unless $pers_id;
#     my $db = $self->{db};
#     my $sql = qq{
#       SELECT annuaire_persphones.phone_id, unit_id, phone_nb, phone_order, phone_hidden, phone_type, room_id, outgoing_right, annuaire_persphones.other_room
#       FROM annuaire_persphones
#       LEFT JOIN annuaire_phones ON annuaire_persphones.phone_id=annuaire_phones.phone_id
#       WHERE pers_id=?
#       AND annuaire_persphones.valid_from <= now() AND (annuaire_persphones.valid_to > now() OR annuaire_persphones.valid_to IS NULL)
#       AND annuaire_phones.valid_from <= now() AND (annuaire_phones.valid_to > now() OR annuaire_phones.valid_to IS NULL)
#       ORDER BY unit_id DESC, phone_order ASC
#     };
#     my $sth = $db->prepare ($sql);
#     unless ($sth) {
#       $self->{errmsg} = "Annuaire::getPersonPhones : $db->{errmsg}";
#       return;
#     }
#     my $rv = $sth->execute ($pers_id);
#     unless ($rv) {
#       $self->{errmsg} = "Annuaire::getPersonPhones : $db->{errmsg}";
#       return;
#     }
#     my $result;
#     my $default_phone;
#     while (my $data = $sth->fetchrow_hashref) {
#         warn "--> Annuaire::getPersonPhones : $pers_id : $data->{phone_nb}, unit_id=$data->{unit_id},$data->{phone_order}\n" if $self->{debug};
#         $default_phone = {
#         phone_id    => $data->{phone_id},
#         phone_nb    => $data->{phone_nb},
#         phone_hidden    => $data->{phone_hidden},
#         phone_order     => $data->{phone_order},
#         phone_type      => $data->{phone_type},
#             room_id         => $data->{room_id},
#             other_room      => $data->{other_room},
#             outgoing_right  => $data->{outgoing_right},
#         } if $data->{unit_id} eq 'default';
#       # unless ($phone_default) {
#       #   $phone_default = $data unless $data->{unit_id};
#       #   next;
#       # }
#       # $data->{phone_default} = 'true' if $phone_default && $phone_default->{phone_nb} eq $data->{phone_nb};
#         my $fromDefault = 'false';
#         $fromDefault = 'true' if ($data->{phone_id} == $default_phone->{phone_id});
#       push @{$result->{$data->{unit_id}}},
#         {
#           phone_id    => $data->{phone_id},
#           phone_nb    => $data->{phone_nb},
#           phone_hidden    => $data->{phone_hidden},
#           phone_order     => $data->{phone_order},
#           phone_type      => $data->{phone_type},
#                 room_id         => $data->{room_id},
#                 other_room      => $data->{other_room},
#                 from_default    => $fromDefault,
#                 outgoing_right  => $data->{outgoing_right},
#         } ;
#     }

#     $sth->finish;
#     return $result;
# }

# sub getPersonAddresses {
#     my ($self, $pers_id) = @_;
#     return unless $pers_id;

#     my $db = $self->{db};
#     my $sql = qq{
#       SELECT *
#       FROM `annuaire_adrspost`
#       WHERE annuaire_adrspost.pers_id = ?
#       AND annuaire_adrspost.valid_from <= now() AND (annuaire_adrspost.valid_to > now() OR annuaire_adrspost.valid_to IS NULL)
#     };
#     my $sth = $db->prepare($sql);

#     unless ($sth) {
#       $self->{errmsg} = "Annuaire::getPersonAddresses : $db->{errmsg}";
#       return;
#     }

#     my $rv = $sth->execute($pers_id);
#     unless ($rv) {
#       $self->{errmsg} = "Annuaire::getPersonAddresses : $db->{errmsg}";
#       return;
#     }

#     my $result;
#     while (my $data = $sth->fetchrow_hashref) {
#         my $address = makePersonAddress($self, $data);

#     $result->{$data->{unit_id}} = $address if $data->{unit_id};
#   }

#     $sth->finish;

#     return $result;
# }

# sub getPersonRooms {
#     my ($self, $pers_id) = @_;
#     return unless $pers_id;
#     my $db = $self->{db};

#     my $sql = qq{
#       SELECT pers_id, unit_id, ap.room_id, room_order, room_hidden, site_id, bat_id, room_abr, ssdin_label, stationpost, 'internal' AS type
#       FROM annuaire_persrooms ap
#       LEFT JOIN dinfo.locaux l ON ap.room_id = l.room_id
#       WHERE ap.pers_id = ?
#       AND ap.room_id > 0
#       AND ap.valid_from <= now() AND (ap.valid_to > now() OR ap.valid_to IS NULL)
#       UNION
#       SELECT pers_id, unit_id, CONCAT('EXT', ap.external_room_id), room_order, room_hidden, '', '', r.name, '', '', 'external' AS type
#       FROM annuaire_persrooms ap
#       LEFT JOIN bottin.rooms r ON ap.external_room_id = r.id
#       WHERE ap.pers_id = ?
#       AND ap.external_room_id > 0
#       AND ap.valid_from <= now() AND (ap.valid_to > now() OR ap.valid_to IS NULL)
#       ORDER BY 2 DESC, 4
#     };

#     my $sth = $db->query($sql, ($pers_id, $pers_id));
#     unless ($sth) {
#       $self->{errmsg} = "Annuaire::getPersonRooms : $db->{errmsg}";
#       return;
#     }

#     my $result;
#     my $default_room;
#     while (my $data = $sth->fetchrow_hashref) {
#         $data->{ssdin_label} = lc $data->{ssdin_label};
#         $data->{ssdin_label} =~ s/\b(\w)/\U$1/g;

#         $default_room = {
#             room_id     => $data->{room_id},
#             room_abr    => $data->{room_abr},
#             room_order  => $data->{room_order},
#             room_hidden => $data->{room_hidden},
#             description => $data->{ssdin_label},
#             type        => $data->{type},
#         } if $data->{unit_id} eq 'default';

#         my $fromDefault = 'false';
#         # $fromDefault = 'true' if ($data->{unit_id} eq 'default');
#         $fromDefault = 'true' if ($data->{room_id} == $default_room->{room_id});

#       push @{$result->{$data->{unit_id}}},
#         {
#                 room_id      => $data->{room_id},
#                 room_abr     => $data->{room_abr},
#                 room_order   => $data->{room_order},
#                 room_hidden  => $data->{room_hidden},
#                 from_default => $fromDefault,
#                 description  => $data->{ssdin_label},
#                 type         => $data->{type},
#         };
#     }
#     $sth->finish;

#     return $result;
# }
