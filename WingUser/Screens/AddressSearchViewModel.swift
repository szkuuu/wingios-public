//
//  AddressSearchViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/25.
//

protocol AddressSearchInputable: ViewModelInputable {}

protocol AddressSearchOutputable: ViewModelOutputable {}

class AddressSearchInput: AddressSearchInputable {}

class AddressSearchOutput: AddressSearchOutputable {}

class AddressSearchViewModel: ViewModel<AddressSearchInput, AddressSearchOutput> {}
