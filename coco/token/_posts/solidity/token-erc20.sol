pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

/******************************************/
/*       ERC20标准的虚币			       */
/******************************************/

contract TokenERC20 {
    string public name;    // public属性，数字货币名称
	
    string public symbol;// 数字货币的符号
    uint8 public decimals = 18; // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply; //货币总供应量

    mapping (address => uint256) public balanceOf;  // 账户-余额 映射关系
    mapping (address => mapping (address => uint256)) public allowance; // 二维数据[a][b]=amount，指账户a授权给b可动用的金额为amount。
	
	/**
	 *
	 * 转账的区块链事件。
	 *
	 **/
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /**
     *
	 * 批准转账申请的区块链事件
	 *
	**/
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
     *
	 * 发行更多货币的区块链事件
	 *
	**/
    event Burn(address indexed from, uint256 value);

    /**
     * 构造函数，用来执行初始化操作。
     *
     * 初始化合约，并给合约的创建者提供一定数额的数字货币
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // 给创建者所有初始货币；
        name = tokenName;                                   // 设置本数字货币的显示名称。
        symbol = tokenSymbol;                               // 设置本数据货币的显示符号。 
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // 避免转账到0x0的空地址。
        require(_to != 0x0);
        // 检查出款账户余额是否足够
        require(balanceOf[_from] >= _value);
        // 检查收款账户是否会溢出。
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // 记录下转账前的两个账户总额，需要确保和转账后是一致的。  
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // 出款账户扣款
        balanceOf[_from] -= _value;
        // 收款账户收款
        balanceOf[_to] += _value;
		// 发送转账事件
        emit Transfer(_from, _to, _value);
        // 确保转账前后两个账户总和是一样的。 
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * 转账
     *
     * 从当前账户转出给定金额到收款人账户上
     *
     * @param _to 收款人账户地址
     * @param _value 金额，指当前货币单位
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * 转账
     *
     * 从出款人账户转出给定金额到收款人账户
     *
     * @param _from 出款人账户地址
     * @param _to 收款人账户地址
     * @param _value 转账金额
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // 检查_from账户中可以由发起人动用的金额。 
        allowance[_from][msg.sender] -= _value;				 // 扣减授权金额
        _transfer(_from, _to, _value); //执行转账
        return true;
    }

    /**
     * 授权某账户允许它从出款人账户上扣款。
     *
     *
     * @param _spender 允许扣款的账户
     * @param _value 允许扣除的最高金额。 
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * 批准并执行从收款账户发起的、从本账户扣款并转账的申请。 
     * 允许 收款账户可以得到比预定金额更多以的币值， 并通知对方。 
     *
     * @param _spender 收款账户
     * @param _value 授权收款账户能够接收的最大币值。 
     * @param _extraData 发送给合约批准方的额外信息。 
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * 销毁货币
     *
     * 从当前账户中销毁 `_value` 额度的货币，本操作不可逆转。 
     *
     * @param _value 待销毁的货币额
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // 检查当前账户的余额是否足够。 
        balanceOf[msg.sender] -= _value;            // 扣减当前账户余额
        totalSupply -= _value;                      // 更新货币总供应量
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * 从特定账户中销毁一定额度的货币
     *
     * 从特定账户_from中销毁 `_value` 额度的货币，本操作不可逆转。 
     *
     * @param _from 货币持有者的账户
     * @param _value 待销毁的货币额
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // 检查目标账户的余额是否足够。 
        require(_value <= allowance[_from][msg.sender]);    // 检查授权给当前用户可动用的余额是否足够。 
        balanceOf[_from] -= _value;                         // 扣减目标账户余额
        allowance[_from][msg.sender] -= _value;             // 扣减授权余额。 
        totalSupply -= _value;                              // 更新总供应量。 
        emit Burn(_from, _value);
        return true;
    }
}
