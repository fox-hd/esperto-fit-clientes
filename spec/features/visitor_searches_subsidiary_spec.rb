require 'rails_helper'

feature 'Visitor searches subsidiary' do
  before do
    allow(Subsidiary).to receive(:all)
      .and_return([Subsidiary.new(id: 1, name: 'Vila Maria', address: 'Avenida Osvaldo Reis, 801',
                                  cnpj: '11189348000195', token: 'CK4XEB'),
                   Subsidiary.new(id: 1, name: 'Super Esperto', address: 'Avenida Ipiranga, 150',
                                  cnpj: '11189348000195', token: 'CK4XEB')])
  end

  scenario 'successfully' do
    allow(Subsidiary).to receive(:search)
      .and_return([Subsidiary.new(id: 1, name: 'EspertoII', address: 'Avenida Paulista, 150',
                                  cnpj: '11189348000195', token: 'CK4XEB')])

    visit root_path
    fill_in 'Busca de filiais', with: 'EspertoII'
    click_on 'Buscar'

    expect(current_path).to eq search_subsidiaries_path
    expect(page).to have_content('EspertoII')
    expect(page).to have_content('Avenida Paulista, 150')
    expect(page).to_not have_content('Super Esperto')
    expect(page).to_not have_content('Avenida Ipiranga, 150')
  end

  scenario 'unsuccessfully' do
    allow(Subsidiary).to receive(:search).and_return([])

    visit root_path
    fill_in 'Busca de filiais', with: 'Butantã'
    click_on 'Buscar'

    expect(page).to_not have_content('EspertoII')
    expect(page).to_not have_content('Avenida Paulista')
    expect(page).to have_content('Nenhuma filial encontrada')
  end

  scenario 'find search case sensitive' do
    allow(Subsidiary).to receive(:search)
      .and_return([Subsidiary.new(id: 1, name: 'EspertoII', address: 'Avenida Paulista, 150',
                                  cnpj: '11189348000195', token: 'CK4XEB')])

    visit root_path
    fill_in 'Busca de filiais', with: 'avenida paulista'
    click_on 'Buscar'

    expect(current_path).to eq search_subsidiaries_path
    expect(page).to have_content('EspertoII')
    expect(page).to have_content('Avenida Paulista, 150')
    expect(page).to_not have_content('Super Esperto')
    expect(page).to_not have_content('Avenida Ipiranga, 150')
  end

  scenario 'search for partial name or neighborhood' do
    allow(Subsidiary).to receive(:search)
      .and_return([Subsidiary.new(id: 1, name: 'EspertoII', address: 'Avenida Paulista, 150',
                                  cnpj: '11189348000195', token: 'CK4XEB'),
                   Subsidiary.new(id: 2, name: 'Nome Novo', address: 'Endereço Esperto, 101',
                                  cnpj: '11189348000195', token: 'CK4XEB')])

    visit root_path
    fill_in 'Busca de filiais', with: 'Esperto'
    click_on 'Buscar'

    expect(page).to have_content('EspertoII')
    expect(page).to have_content('Nome Novo')
    expect(page).to_not have_content('Diferentão')
  end
end
