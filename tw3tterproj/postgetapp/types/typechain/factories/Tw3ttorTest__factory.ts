/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type { Tw3ttorTest, Tw3ttorTestInterface } from "../Tw3ttorTest";

const _abi = [
  {
    inputs: [
      {
        internalType: "string",
        name: "_tw33tting",
        type: "string",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "_tw33tting",
        type: "string",
      },
    ],
    name: "setTw33tter",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "tw33tter",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

const _bytecode =
  "0x608060405234801561001057600080fd5b506040516200085138038062000851833981016040819052610031916101c5565b61005e6040518060600160405280602281526020016200082f602291398261007860201b6101c41760201c565b80516100719060009060208401906100e6565b5050610306565b6100c1828260405160240161008e92919061029d565b60408051601f198184030181529190526020810180516001600160e01b03908116634b5c427760e01b179091526100c516565b5050565b80516a636f6e736f6c652e6c6f67602083016000808483855afa5050505050565b8280546100f2906102cb565b90600052602060002090601f016020900481019282610114576000855561015a565b82601f1061012d57805160ff191683800117855561015a565b8280016001018555821561015a579182015b8281111561015a57825182559160200191906001019061013f565b5061016692915061016a565b5090565b5b80821115610166576000815560010161016b565b634e487b7160e01b600052604160045260246000fd5b60005b838110156101b0578181015183820152602001610198565b838111156101bf576000848401525b50505050565b6000602082840312156101d757600080fd5b81516001600160401b03808211156101ee57600080fd5b818401915084601f83011261020257600080fd5b8151818111156102145761021461017f565b604051601f8201601f19908116603f0116810190838211818310171561023c5761023c61017f565b8160405282815287602084870101111561025557600080fd5b610266836020830160208801610195565b979650505050505050565b60008151808452610289816020860160208601610195565b601f01601f19169290920160200192915050565b6040815260006102b06040830185610271565b82810360208401526102c28185610271565b95945050505050565b600181811c908216806102df57607f821691505b6020821081141561030057634e487b7160e01b600052602260045260246000fd5b50919050565b61051980620003166000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c8063062e018b1461003b578063fbeae88514610059575b600080fd5b61004361006e565b604051610050919061035c565b60405180910390f35b61006c61006736600461038c565b610100565b005b60606000805461007d9061043d565b80601f01602080910402602001604051908101604052809291908181526020018280546100a99061043d565b80156100f65780601f106100cb576101008083540402835291602001916100f6565b820191906000526020600020905b8154815290600101906020018083116100d957829003601f168201915b5050505050905090565b6101ad6040518060600160405280602381526020016104ea60239139600080546101299061043d565b80601f01602080910402602001604051908101604052809291908181526020018280546101559061043d565b80156101a25780601f10610177576101008083540402835291602001916101a2565b820191906000526020600020905b81548152906001019060200180831161018557829003601f168201915b505050505083610209565b80516101c0906000906020840190610276565b5050565b6101c082826040516024016101da929190610478565b60408051601f198184030181529190526020810180516001600160e01b0316634b5c427760e01b179052610255565b610250838383604051602401610221939291906104a6565b60408051601f198184030181529190526020810180516001600160e01b0316632ced7cef60e01b179052610255565b505050565b80516a636f6e736f6c652e6c6f67602083016000808483855afa5050505050565b8280546102829061043d565b90600052602060002090601f0160209004810192826102a457600085556102ea565b82601f106102bd57805160ff19168380011785556102ea565b828001600101855582156102ea579182015b828111156102ea5782518255916020019190600101906102cf565b506102f69291506102fa565b5090565b5b808211156102f657600081556001016102fb565b6000815180845260005b8181101561033557602081850181015186830182015201610319565b81811115610347576000602083870101525b50601f01601f19169290920160200192915050565b60208152600061036f602083018461030f565b9392505050565b634e487b7160e01b600052604160045260246000fd5b60006020828403121561039e57600080fd5b813567ffffffffffffffff808211156103b657600080fd5b818401915084601f8301126103ca57600080fd5b8135818111156103dc576103dc610376565b604051601f8201601f19908116603f0116810190838211818310171561040457610404610376565b8160405282815287602084870101111561041d57600080fd5b826020860160208301376000928101602001929092525095945050505050565b600181811c9082168061045157607f821691505b6020821081141561047257634e487b7160e01b600052602260045260246000fd5b50919050565b60408152600061048b604083018561030f565b828103602084015261049d818561030f565b95945050505050565b6060815260006104b9606083018661030f565b82810360208401526104cb818661030f565b905082810360408401526104df818561030f565b969550505050505056fe4368616e67696e67206772656574696e672066726f6d202725732720746f2027257327a164736f6c634300080b000a4465706c6f79696e67206120477265657465722077697468206772656574696e673a";

export class Tw3ttorTest__factory extends ContractFactory {
  constructor(
    ...args: [signer: Signer] | ConstructorParameters<typeof ContractFactory>
  ) {
    if (args.length === 1) {
      super(_abi, _bytecode, args[0]);
    } else {
      super(...args);
    }
  }

  deploy(
    _tw33tting: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<Tw3ttorTest> {
    return super.deploy(_tw33tting, overrides || {}) as Promise<Tw3ttorTest>;
  }
  getDeployTransaction(
    _tw33tting: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(_tw33tting, overrides || {});
  }
  attach(address: string): Tw3ttorTest {
    return super.attach(address) as Tw3ttorTest;
  }
  connect(signer: Signer): Tw3ttorTest__factory {
    return super.connect(signer) as Tw3ttorTest__factory;
  }
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): Tw3ttorTestInterface {
    return new utils.Interface(_abi) as Tw3ttorTestInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): Tw3ttorTest {
    return new Contract(address, _abi, signerOrProvider) as Tw3ttorTest;
  }
}