module ApplicationHelper

  # forms for input phone: +41216937526, 0041216937526, 0216937526, 7526
  def phone_link(phone, opts={})
    sep = '&nbsp;'
    p=phone.gsub(/ /, '').sub(/^00/, '+')
    if p.length > 5
            p = "+41" << p[1..9] if p =~ /^0/
    else
            p = "+412169#{p}"
    end
    p = "+41216931111" unless /^\+[0-9]{11}$/.match?(p)
    pl = p[0..2] << sep << p[3..4] << sep << p[5..7] << sep << p[8..9] << sep << p[10..11]
    cp = @client_from_epfl ? "tel" : "callto"
    link_to(pl.html_safe, "#{cp}:#{p}", opts)
  end

  def link_to_or_text(txt, url, opts={})
    if url.present?
      link_to(txt, url, opts)
    else
      txt
    end
  end

  # Return the full url for static stuff coming from EPFL elements cdn
  def belurl(path)
    "https://epfl-si.github.io/elements/#{path}"
  end
end


# sub norm_phone {
#   my $phone = shift;
#   return unless $phone;
#   $phone =~ s/ //g;
#   my $phone_link;
#   if (length ($phone) > 5) {
#     if ($phone =~ /^\+/) {
#       my $phone_nb = substr($phone,0,3).' '.substr($phone,3, 2).' '.substr($phone,5, 3).' '.substr($phone,8, 2).' '.substr($phone,10, 2);
#       $phone_link = qq{<a href="$CALLPROTOCOL:$phone">$phone_nb</a>};
#       $phone = $phone_nb;
#     } else {
#       if ($phone =~ /^00/) {
#       } elsif ($phone =~ /^0/) {
#         my $zone = substr ($phone, 1, 2);
#         $phone =~ s/^0$zone//;
#         my $phone_nb = substr($phone,0,3).' '.substr($phone,3, 2).' '.substr($phone,5, 2);
#         $phone = "+41 $zone ".$phone_nb;
#       }
#       my $tmpphone = $phone;
#          $tmpphone =~ s/ //g;
#       $phone_link = qq{<a href="$CALLPROTOCOL:$tmpphone">$phone</a>};
#     }
#   } else {
#       my $phone_nb = substr($phone,0,1).' '.substr($phone,1, 2).' '.substr($phone,3, 4);
#       $phone_link = qq{<a href="$CALLPROTOCOL:+412169$phone">+41 21 69$phone_nb</a>};
#       $phone = qq{+41 21 69$phone_nb};
#   }
#   return ($phone, $phone_link);

# }
