import React, { useState } from 'react';
import { AlertCircle, Leaf, Send, Split, ShoppingCart, Award, BarChart3, Zap, FileText } from 'lucide-react';

const GreenRewardUI = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [credits, setCredits] = useState([
    { id: 1, amount: 1000, price: 50, type: 'Solar Farm', standard: 'VCS', verified: true, forSale: false, retired: false, fractional: false },
    { id: 2, amount: 500, price: 55, type: 'Wind Power', standard: 'Gold Standard', verified: true, forSale: true, retired: false, fractional: false },
    { id: 3, amount: 250, price: 48, type: 'Reforestation', standard: 'VCS', verified: false, forSale: false, retired: false, fractional: true },
  ]);

  const [transferForm, setTransferForm] = useState({ creditId: '', recipient: '' });
  const [fractionalizeForm, setFractionalizeForm] = useState({ creditId: '', fractions: 2 });
  const [issueForm, setIssueForm] = useState({ amount: '', price: '', type: '', standard: '' });

  const stats = {
    totalCredits: credits.reduce((sum, c) => sum + c.amount, 0),
    totalRetired: 0,
    totalValue: credits.reduce((sum, c) => sum + (c.amount * c.price), 0),
    verified: credits.filter(c => c.verified).length
  };

  const handleTransfer = () => {
    if (!transferForm.creditId || !transferForm.recipient) {
      alert('Please fill all fields');
      return;
    }
    console.log('Transferring credit:', transferForm);
    alert(`Transfer initiated!\nCredit ID: ${transferForm.creditId}\nRecipient: ${transferForm.recipient}`);
    setTransferForm({ creditId: '', recipient: '' });
  };

  const handleFractionalize = () => {
    if (!fractionalizeForm.creditId) {
      alert('Please select a credit');
      return;
    }
    console.log('Fractionalizing:', fractionalizeForm);
    alert(`Credit split into ${fractionalizeForm.fractions} fractions!`);
    setFractionalizeForm({ creditId: '', fractions: 2 });
  };

  const handleIssue = () => {
    if (!issueForm.amount || !issueForm.price || !issueForm.type || !issueForm.standard) {
      alert('Please fill all fields');
      return;
    }
    const newCredit = {
      id: credits.length + 1,
      amount: parseInt(issueForm.amount),
      price: parseInt(issueForm.price),
      type: issueForm.type,
      standard: issueForm.standard,
      verified: false,
      forSale: false,
      retired: false,
      fractional: false
    };
    setCredits([...credits, newCredit]);
    alert('Credit issued successfully!');
    setIssueForm({ amount: '', price: '', type: '', standard: '' });
  };

  const TabButton = ({ id, icon: Icon, label }) => (
    <button
      onClick={() => setActiveTab(id)}
      className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
        activeTab === id
          ? 'bg-green-600 text-white shadow-lg'
          : 'bg-white text-gray-700 hover:bg-green-50'
      }`}
    >
      <Icon size={18} />
      {label}
    </button>
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-emerald-100 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="bg-green-600 p-3 rounded-xl">
                <Leaf className="text-white" size={32} />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-800">GreenReward</h1>
                <p className="text-gray-600">Decentralized Carbon Credit Marketplace</p>
              </div>
            </div>
            <div className="flex gap-3">
              <div className="text-right">
                <p className="text-sm text-gray-600">Wallet</p>
                <p className="font-mono text-sm text-gray-800">ST1H...X9K2</p>
              </div>
              <button className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors">
                Connect Wallet
              </button>
            </div>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center gap-3 mb-2">
              <Award className="text-green-600" size={24} />
              <h3 className="text-gray-600 text-sm">Total Credits</h3>
            </div>
            <p className="text-3xl font-bold text-gray-800">{stats.totalCredits.toLocaleString()}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center gap-3 mb-2">
              <Zap className="text-blue-600" size={24} />
              <h3 className="text-gray-600 text-sm">Verified</h3>
            </div>
            <p className="text-3xl font-bold text-gray-800">{stats.verified}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center gap-3 mb-2">
              <BarChart3 className="text-purple-600" size={24} />
              <h3 className="text-gray-600 text-sm">Portfolio Value</h3>
            </div>
            <p className="text-3xl font-bold text-gray-800">${(stats.totalValue / 1000).toFixed(1)}k</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center gap-3 mb-2">
              <FileText className="text-orange-600" size={24} />
              <h3 className="text-gray-600 text-sm">Retired</h3>
            </div>
            <p className="text-3xl font-bold text-gray-800">{stats.totalRetired}</p>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
          <TabButton id="dashboard" icon={BarChart3} label="Dashboard" />
          <TabButton id="transfer" icon={Send} label="Transfer" />
          <TabButton id="fractionalize" icon={Split} label="Fractionalize" />
          <TabButton id="marketplace" icon={ShoppingCart} label="Marketplace" />
          <TabButton id="issue" icon={Leaf} label="Issue Credits" />
        </div>

        {/* Main Content */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          {activeTab === 'dashboard' && (
            <div>
              <h2 className="text-2xl font-bold text-gray-800 mb-6 flex items-center gap-2">
                <BarChart3 className="text-green-600" />
                My Carbon Credits
              </h2>
              <div className="space-y-4">
                {credits.map(credit => (
                  <div key={credit.id} className="border border-gray-200 rounded-xl p-6 hover:shadow-lg transition-shadow">
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2 flex-wrap">
                          <h3 className="text-xl font-semibold text-gray-800">Credit #{credit.id}</h3>
                          {credit.verified && (
                            <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-medium">
                              ✓ Verified
                            </span>
                          )}
                          {credit.fractional && (
                            <span className="bg-purple-100 text-purple-700 px-3 py-1 rounded-full text-xs font-medium">
                              Fractional
                            </span>
                          )}
                          {credit.forSale && (
                            <span className="bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-xs font-medium">
                              For Sale
                            </span>
                          )}
                        </div>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                          <div>
                            <p className="text-gray-600">Amount</p>
                            <p className="font-semibold text-gray-800">{credit.amount} units</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Price</p>
                            <p className="font-semibold text-gray-800">{credit.price} STX/unit</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Project Type</p>
                            <p className="font-semibold text-gray-800">{credit.type}</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Standard</p>
                            <p className="font-semibold text-gray-800">{credit.standard}</p>
                          </div>
                        </div>
                      </div>
                      <div className="flex gap-2 ml-4">
                        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm">
                          Sell
                        </button>
                        <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors text-sm">
                          Retire
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'transfer' && (
            <div>
              <h2 className="text-2xl font-bold text-gray-800 mb-6 flex items-center gap-2">
                <Send className="text-green-600" />
                Transfer Credits
              </h2>
              <div className="max-w-2xl">
                <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-6">
                  <div className="flex gap-3">
                    <AlertCircle className="text-blue-600 flex-shrink-0" size={20} />
                    <div className="text-sm text-blue-800">
                      <p className="font-semibold mb-1">Zero Fee Transfers</p>
                      <p>Send credits directly to any Stacks address without marketplace fees. Only gas costs apply.</p>
                    </div>
                  </div>
                </div>
                <div className="space-y-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Credit ID
                    </label>
                    <select
                      value={transferForm.creditId}
                      onChange={(e) => setTransferForm({...transferForm, creditId: e.target.value})}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                    >
                      <option value="">Select a credit to transfer</option>
                      {credits.filter(c => !c.forSale && !c.retired).map(c => (
                        <option key={c.id} value={c.id}>
                          Credit #{c.id} - {c.amount} units ({c.type})
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Recipient Address
                    </label>
                    <input
                      type="text"
                      value={transferForm.recipient}
                      onChange={(e) => setTransferForm({...transferForm, recipient: e.target.value})}
                      placeholder="ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent font-mono"
                    />
                  </div>
                  <button
                    onClick={handleTransfer}
                    className="w-full bg-green-600 text-white py-3 rounded-lg hover:bg-green-700 transition-colors font-semibold flex items-center justify-center gap-2"
                  >
                    <Send size={20} />
                    Transfer Credit
                  </button>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'fractionalize' && (
            <div>
              <h2 className="text-2xl font-bold text-gray-800 mb-6 flex items-center gap-2">
                <Split className="text-green-600" />
                Fractionalize Credits
              </h2>
              <div className="max-w-2xl">
                <div className="bg-purple-50 border border-purple-200 rounded-xl p-4 mb-6">
                  <div className="flex gap-3">
                    <AlertCircle className="text-purple-600 flex-shrink-0" size={20} />
                    <div className="text-sm text-purple-800">
                      <p className="font-semibold mb-1">Split Credits for Better Liquidity</p>
                      <p>Divide large credits into 2-50 smaller fractions for flexible trading and transfers.</p>
                    </div>
                  </div>
                </div>
                <div className="space-y-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Credit to Split
                    </label>
                    <select
                      value={fractionalizeForm.creditId}
                      onChange={(e) => setFractionalizeForm({...fractionalizeForm, creditId: e.target.value})}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    >
                      <option value="">Select a credit</option>
                      {credits.filter(c => !c.forSale && !c.retired && !c.fractional).map(c => (
                        <option key={c.id} value={c.id}>
                          Credit #{c.id} - {c.amount} units ({c.type})
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Number of Fractions (2-50)
                    </label>
                    <input
                      type="number"
                      min="2"
                      max="50"
                      value={fractionalizeForm.fractions}
                      onChange={(e) => setFractionalizeForm({...fractionalizeForm, fractions: parseInt(e.target.value)})}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    />
                  </div>
                  <button
                    onClick={handleFractionalize}
                    className="w-full bg-purple-600 text-white py-3 rounded-lg hover:bg-purple-700 transition-colors font-semibold flex items-center justify-center gap-2"
                  >
                    <Split size={20} />
                    Split Credit
                  </button>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'marketplace' && (
            <div>
              <h2 className="text-2xl font-bold text-gray-800 mb-6 flex items-center gap-2">
                <ShoppingCart className="text-green-600" />
                Marketplace
              </h2>
              <div className="space-y-4">
                {credits.filter(c => c.forSale).map(credit => (
                  <div key={credit.id} className="border border-gray-200 rounded-xl p-6 hover:shadow-lg transition-shadow">
                    <div className="flex justify-between items-center">
                      <div>
                        <h3 className="text-xl font-semibold text-gray-800 mb-2">
                          {credit.type} - {credit.standard}
                        </h3>
                        <div className="flex gap-6 text-sm">
                          <div>
                            <p className="text-gray-600">Available</p>
                            <p className="font-semibold text-gray-800">{credit.amount} units</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Price</p>
                            <p className="font-semibold text-gray-800">{credit.price} STX/unit</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Total Value</p>
                            <p className="font-semibold text-gray-800">{(credit.amount * credit.price).toLocaleString()} STX</p>
                          </div>
                        </div>
                      </div>
                      <button className="bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 transition-colors font-semibold">
                        Purchase
                      </button>
                    </div>
                  </div>
                ))}
                {credits.filter(c => c.forSale).length === 0 && (
                  <div className="text-center py-12 text-gray-500">
                    <ShoppingCart size={48} className="mx-auto mb-4 opacity-50" />
                    <p>No credits currently listed for sale</p>
                  </div>
                )}
              </div>
            </div>
          )}

          {activeTab === 'issue' && (
            <div>
              <h2 className="text-2xl font-bold text-gray-800 mb-6 flex items-center gap-2">
                <Leaf className="text-green-600" />
                Issue New Credits
              </h2>
              <div className="max-w-2xl">
                <div className="space-y-6">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Amount (units)
                      </label>
                      <input
                        type="number"
                        value={issueForm.amount}
                        onChange={(e) => setIssueForm({...issueForm, amount: e.target.value})}
                        placeholder="1000"
                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Price (STX/unit)
                      </label>
                      <input
                        type="number"
                        value={issueForm.price}
                        onChange={(e) => setIssueForm({...issueForm, price: e.target.value})}
                        placeholder="50"
                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Project Type
                    </label>
                    <input
                      type="text"
                      value={issueForm.type}
                      onChange={(e) => setIssueForm({...issueForm, type: e.target.value})}
                      placeholder="Solar Farm, Wind Power, Reforestation..."
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Verification Standard
                    </label>
                    <select
                      value={issueForm.standard}
                      onChange={(e) => setIssueForm({...issueForm, standard: e.target.value})}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                    >
                      <option value="">Select standard</option>
                      <option value="VCS">VCS (Verified Carbon Standard)</option>
                      <option value="Gold Standard">Gold Standard</option>
                      <option value="CDM">CDM (Clean Development Mechanism)</option>
                      <option value="CAR">CAR (Climate Action Reserve)</option>
                    </select>
                  </div>
                  <button
                    onClick={handleIssue}
                    className="w-full bg-green-600 text-white py-3 rounded-lg hover:bg-green-700 transition-colors font-semibold flex items-center justify-center gap-2"
                  >
                    <Leaf size={20} />
                    Issue Credits
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="mt-8 text-center text-gray-600 text-sm">
          <p>GreenReward - Decentralized Carbon Credit Marketplace</p>
          <p className="mt-1">Built on Stacks Blockchain with IoT Verification</p>
        </div>
      </div>
    </div>
  );
};

export default GreenRewardUI;