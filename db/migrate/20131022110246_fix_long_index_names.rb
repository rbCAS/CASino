class FixLongIndexNames < ActiveRecord::Migration
  def change
    # Long names prevent us from doing some migrations, because the resulting
    # temporary index names would be longer than 64 characters:
    # Index name 'temp_index_altered_casino_proxy_tickets_on_proxy_granting_ticket_id' on table
    # 'altered_casino_proxy_tickets' is too long; the limit is 64 characters
    remove_index :casino_service_tickets, :ticket_granting_ticket_id
    remove_index :casino_proxy_tickets, :proxy_granting_ticket_id
    add_index :casino_service_tickets, :ticket_granting_ticket_id, name: 'casino_service_tickets_on_tgt_id'
    add_index :casino_proxy_tickets, :proxy_granting_ticket_id, name: 'casino_proxy_tickets_on_pgt_id'
  end
end
